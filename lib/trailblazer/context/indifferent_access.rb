module Trailblazer
  class Context
    class IndifferentAccess < Context
      def [](name)
        # TODO: well...
        @mutable_options.key?(name.to_sym) and return @mutable_options[name.to_sym]
        @mutable_options.key?(name.to_s) and return @mutable_options[name.to_s]
        @wrapped_options.key?(name.to_sym) and return @wrapped_options[name.to_sym]
        @wrapped_options[name.to_s]
      end

      def key?(name)
        super(name.to_sym) || super(name.to_s)
      end

    end
  end
end
