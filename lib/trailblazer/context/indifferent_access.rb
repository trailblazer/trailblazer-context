module Trailblazer
  class Context
    class IndifferentAccess < Context
      def [](name)
        # TODO: well...
        boolean?(name) and return nil
        @mutable_options.key?(name.to_sym) and return @mutable_options[name.to_sym]
        @mutable_options.key?(name.to_s) and return @mutable_options[name.to_s]
        @wrapped_options.key?(name.to_sym) and return @wrapped_options[name.to_sym]
        @wrapped_options[name.to_s]
      end

      def key?(name)
        boolean?(name) and return false
        super(name.to_sym) || super(name.to_s)
      end

      private

      def boolean?(name)
        name.nil? || name.is_a?(TrueClass) || name.is_a?(FalseClass)
      end
    end
  end
end
