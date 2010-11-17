direc = File.dirname(__FILE__)

require "#{direc}/tweak/version.rb"
require 'object2module'
require 'remix'

module Tweak
  module ObjectExtensions

    # Temporarily augment the top-level classes/modules of the same
    # name as those defined in the using-module for the duration of
    # the block.
    # @yield The block where the functionality shall be available.
    # @return The value of the block
    # @param [Module, Symbol] name The using-module, may either be the
    #   name of the using-module as a Symbol or the actual Module itself
    # @example
    #   module Tweaks
    #     class String
    #       def hello() :hello end
    #     end
    #   end
    #
    #   using Tweaks do
    #     "john".hello #=> :hello
    #   end
    #
    #   "john".hello #=> NoMethodError
    def using(name, &block)
      mod = name
      if name.instance_of?(Symbol)
        mod = Object.const_get(name)
      end
      
      raise "name is not a Module or a Symbol" if !mod.instance_of?(Module)

      tweaks = {}
      begin
        mod.constants.each do |v|
          tweaked_source = mod.const_get(v)
          
          # Only include the class/module from the using-module if:
          # 1. The class/module in the using-module is a module (or class)
          # 2. A corresponding module (or class) is found at top-level
          next if !tweaked_source.instance_of?(Module) && !Object.const_defined?(v) &&
            !Object.const_get(v).instance_of?(Module)
          
          tweak_dest = Object.const_get(v)
          tweak_source = mod.const_get(v)
          tweak_dest.gen_include(tweak_source)
          tweaks[tweak_dest] = tweaked_source
        end
        
        yield
        
      ensure

        # Uninclude all the using-module classes/modules
        tweaks.each do |tweak_dest, tweak_source|
          tweak_dest.uninclude(tweak_source, true)
        end
      end
    end
  end
end

class Object
  include Tweak::ObjectExtensions
end

