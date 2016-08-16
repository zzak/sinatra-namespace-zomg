require 'sinatra/base'

module Sinatra
  module Namespace
    module NestedMethods
      #DONT_FORWARD = %w[call configure disable enable new register reset! run! set use template layout]
      attr_reader :prefix, :options, :base

      def get(name = nil, options = {}, &block)
        prefixed(:get, name, options, &block)
      end

      def put(name = nil, options = {}, &block)
        prefixed(:put, name, options, &block)
      end

      def post(name = nil, options = {}, &block)
        prefixed(:post, name, options, &block)
      end

      def delete(name = nil, options = {}, &block)
        prefixed(:delete, name, options, &block)
      end

      def head(name = nil, options = {}, &block)
        prefixed(:head, name, options, &block)
      end

      def before(name = "*", &block)
        prefixed(:before, name, &block)
      end

      def after(name = "*", &block)
        prefixed(:after, name, &block)
      end

      private

      def prefixed_path(name)
        #a = Mustermann.new(prefix.to_s, type: :regular)
        #puts "name.to_s: #{name.to_s} is a #{name.inspect}"
        #puts "join them: #{Mustermann.new(prefix.to_s + name.to_s, type: :regular)}"
        ##b = Mustermann.new(name.to_s, type: :regular)
        #puts [a, b]
        #a + b
        Mustermann.new(prefix.to_s + name.to_s, type: :regular)
      end

      def prefixed(method, name, *args, &block)
        base.send(method, prefixed_path(name), *args, &block)
      end

      #def forward?(name)
      #  not DONT_FORWARD.include? name.to_s
      #end

      def method_missing(name, *args, &block)
        return super unless base.respond_to? name# and forward? name
        base.send(name, *args, &block)
      end
    end

    module ClassMethods
      def namespace(prefix = nil, options = {}, &block)
        Namespace.setup(self, prefix, options, Module.new, &block)
      end
    end

    module ModularMethods
      def setup(base, prefix = nil, options = {}, mixin = nil, &block)
        prefix ||= ""
        mixin ||= self
        mixin.class_eval { @prefix, @options, @base = prefix, options, base }

        mixin.extend ClassMethods, NestedMethods
        mixin.before { extend mixin }
        mixin.class_eval(&block) if block_given?
        mixin
      end
    end

    extend ModularMethods

    def self.included(klass)
      klass.extend ModularMethods
      super
    end

    def self.registered(klass)
      klass.extend ClassMethods
    end
  end

  register Namespace
end
