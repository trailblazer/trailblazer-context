module Trailblazer
  class Context
    module Aliasing
      def initialize(wrapped_options, mutable_options, (ctx, flow_options), circuit_options)
        super(wrapped_options, mutable_options)

        @aliases = (flow_options[:context_alias] || {}).invert
      end

      def [](key)
        return super unless aka = @aliases[key] # yepp, nil/false won't work
        super(aka)
      end

      def key?(key)
        return super unless aka = @aliases[key] # yepp, nil/false won't work
        super(aka)
      end
    end
  end
end
