require 'sinatra/namespace'
require 'rack/test'

module SpecHelpers
  include Rack::Test::Methods

  def app(app=nil)
    app || Sinatra::Application
  end
end

RSpec.configure do |config|
  config.include SpecHelpers
end

describe Sinatra::Namespace do
  [:get, :head, :post, :put, :delete].each do |verb|
    describe "HTTP #{verb.to_s.upcase}" do
      before :each do
        Object.send :remove_const, :App if Object.const_defined? :App
        class ::App < Sinatra::Base
          register Sinatra::Namespace
        end
        app App
      end

      describe :namespace do
        it "should add routes including the prefix to the base app" do
          app.namespace "/foo" do
            send(verb, "/bar") { "baz" }
          end

          send(verb, "/foo/bar").should be_ok
          send(verb, "/foo/bar").body.should == "baz" unless verb == :head
        end

        it "should allows adding routes with no path" do
          app.namespace "/foo" do
            send(verb) { "bar" }
          end
          send(verb, "/foo").should be_ok
          send(verb, "/foo").body.should == "bar" unless verb == :head
        end

        it "allows nesting" do
          app.namespace "/foo" do
            namespace "/bar" do
              namespace "/baz" do
                send(verb) { 'foobarbaz' }
              end
            end
          end
          send(verb, "/foo/bar/baz").should be_ok
          send(verb, "/foo/bar/baz").body.should == "foobarbaz" unless verb == :head
        end

        it "allows regular expressions" do
          # /\A\(\?\-mix\:(.*)\)\Z/
          # "(?-mix:\\/\\d\\d)*"
          app.namespace %r{/\d\d} do
            send(verb) { "foo" }
            namespace %r{/\d\d} do
              send(verb) { "bar" }
            end
            namespace "/0000" do
              send(verb) { "baz" }
            end
          end
          send(verb, '/20').should be_ok
          send(verb, '/20').body.should == "foo" unless verb == :head
          send(verb, '/20/20').should be_ok
          send(verb, '/20/20').body.should == "bar" unless verb == :head
          send(verb, '/20/0000').should be_ok
          send(verb, '/20/0000').body.should == "baz" unless verb == :head
          send(verb, '/20/200').should_not be_ok
        end
      end

      describe :filters do
        it 'should trigger before filters for namespaces' do
          app.before { settings.set :foo, 0 }
          app.namespace('/foo') do
            before { settings.set :foo, settings.foo + 1 }
            send(verb) { }
          end
          send(verb, '/foo').should be_ok
          app.foo.should == 1
        end

        it 'should trigger after filters for namespaces' do
          puts "foo is #{$foo}"
          $foo = 0
          puts "foo is now #{$foo}"
          app.after { puts "app.after called"; $foo += 2 }
          app.namespace('/foo') do
            after { puts "namespace.after called"; $foo += 1 }
            send(verb) { }
          end
          send(verb, '/foo').should be_ok
          $foo.should == 3
          3.times { puts nil }
        end
      end
    end
  end
end
