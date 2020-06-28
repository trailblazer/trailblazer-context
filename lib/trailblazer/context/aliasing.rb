module Trailblazer
  class Context
    module Aliasing
      def initialize(wrapped_options, mutable_options, context_alias: {}, **)
        super(wrapped_options, mutable_options)

        @aliases = context_alias.invert
      end

      def [](key)
        return super unless (aka = @aliases[key]) # yepp, nil/false won't work

        super(aka)
      end

      def key?(key)
        return super unless (aka = @aliases[key]) # yepp, nil/false won't work

        super(aka)
      end

      # @private ?
      def merge(hash)
        original, mutable_options = decompose

        self.class.new(
          original,
          mutable_options.merge(hash),
          context_alias: @aliases.invert # DISCUSS: maybe we can speed up by remembering the original options?
        )
      end

      def to_hash
        super.merge(Hash[@aliases.collect { |aka, k| key?(k) ? [aka, self[k]] : nil }.compact]) # FIXME: performance!
      end
    end
  end
end
