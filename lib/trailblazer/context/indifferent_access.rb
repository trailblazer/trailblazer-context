require "trailblazer/context/aliasing"

module Trailblazer
  class Context
    class IndifferentAccess < Context
      module InstanceMethods
        def [](name)
          # TODO: well...
          @mutable_options.key?(name.to_sym) and return @mutable_options[name.to_sym]
          @mutable_options.key?(name.to_s) and return @mutable_options[name.to_s]
          @wrapped_options.key?(name.to_sym) and return @wrapped_options[name.to_sym]
          @wrapped_options[name.to_s]
        end

        def self.build(wrapped_options, (ctx, flow_options), circuit_options)
          new(wrapped_options, {}, flow_options)
        end
      end
      include InstanceMethods

      def key?(name)
        super(name.to_sym) || super(name.to_s)
      end

      include Aliasing # FIXME

      def self.build(wrapped_options, mutable_options, (ctx, flow_options), circuit_options)
        new(wrapped_options, {}, **flow_options)
      end
    end
  end
end
