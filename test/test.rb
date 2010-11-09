direc = File.dirname(__FILE__)
require 'rubygems'
require 'bacon'
require "#{direc}/../lib/tweak"

class Module
  public :include, :remove_const
end

puts "testing Tweak version #{Tweak::VERSION}..."

describe Object2module do
  before do
    module Tweaks
      
      class String
        def hello
          :hello
        end
      end

      class Fixnum
        def bye
          :bye
        end
      end
      
    end
  end

  after do
    Object.remove_const(:Tweaks)
  end

  describe 'using' do
    it 'tweaks functionality of String and Fixnum classes for duration of block' do
      lambda { "john".hello }.should.raise NoMethodError
      lambda { 5.bye }.should.raise NoMethodError
      
      using Tweaks do
        "john".hello.should == :hello
        5.bye.should == :bye
      end

      lambda { "john".hello }.should.raise NoMethodError
      lambda { 5.bye }.should.raise NoMethodError
    end
  end
end
