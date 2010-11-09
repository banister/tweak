direc = File.dirname(__FILE__)


require "#{direc}/tweak/version.rb"
require 'object2module'
require 'remix'

module Tweak
  module ObjectExtensions
    def using(name, &block)
      mod = name
      if name.instance_of?(Symbol)
        mod = Object.const_get(name)
      end
      raise "name is not a Module or a Symbol" if !mod.instance_of?(Module)

      should_skip = lambda do |const, tweak_source| !tweak_source.instance_of?(Module) ||
        !Object.const_defined?(const) ||
        !Object.const_get(const).instance_of?(Module)
      end

      @__tweaks__ = {}
      begin
        mod.constants.each do |const|
          tweak_source = mod.const_get(const)

          next if !tweak_source.instance_of?(Module) ||
        !Object.const_defined?(const) ||
        !Object.const_get(const).instance_of?(Module)
          
          tweak_dest = Object.const_get(const)
          tweak_source = mod.const_get(const)
          tweak_dest.gen_include(tweak_source)
          @__tweaks__[tweak_dest] = tweak_source
        end
        
        yield
      ensure
        @__tweaks__.each do |tweak_dest, tweak_source|
          tweak_dest.uninclude(tweak_source)
        end
        remove_instance_variable(:@__tweaks__)
      end
    end
  end
end
        
        
class Object
  include Tweak::ObjectExtensions
end


