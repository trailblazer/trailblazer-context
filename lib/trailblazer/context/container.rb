require "forwardable"
require_relative "store/indifferent_access"

module Trailblazer
  module Context
    class Container
      autoload :WithAliases, "trailblazer/context/container/with_aliases"

      def self.build(*args, **options)
        return WithAliases.new(*args, **options) if options.key?(:aliases)
        new(*args, **options)
      end

      def initialize(wrapped_options, mutable_options, replica_class: Context::Store::IndifferentAccess, **)
        @wrapped_options  = wrapped_options
        @mutable_options  = mutable_options
        @replica_class    = replica_class

        @replica = initialize_replica_store
      end

      # Return the Context's two components. Used when computing the new output for
      # the next activity.
      def decompose
        [@wrapped_options, @mutable_options]
      end

      def inspect
        %{#<Trailblazer::Context::Container wrapped_options=#{@wrapped_options} mutable_options=#{@mutable_options}>}
      end
      alias_method :to_s, :inspect

      private def initialize_replica_store
        @replica_class.new(@wrapped_options, @mutable_options)
      end

      # Some common methods made available directly in Context::Container for
      # performance tuning, extensions and to avoid `@replica` delegations.
      module CommonMethods
        def [](key)
          @replica[key]
        end

        def []=(key, value)
          @replica[key] = value
          @mutable_options[key] = value
        end
        alias_method :store, :[]=

        def delete(key)
          @replica.delete(key)
          @mutable_options.delete(key)
        end

        def merge(other_hash)
          self.class.new(
            @wrapped_options,
            @mutable_options.merge(other_hash),
            replica_class: @replica_class,
          )
        end

        def fetch(key, default = nil, &block)
          @replica.fetch(key, default, &block)
        end

        def keys; @replica.keys; end

        def key?(key); @replica.key?(key); end

        def values; @replica.values; end

        def value?(value); @replica.value?(value); end

        def to_hash; @replica.to_hash; end

        def each(&block); @replica.each(&block); end
        include Enumerable
      end

      # Additional methods being forwarded on Context::Container
      # NOTE: def_delegated method calls incurs additional cost
      # compared to actual method defination calls.
      # https://github.com/JuanitoFatas/fast-ruby/pull/182
      module Delegations
        extend Forwardable
        def_delegators :@replica,
          :default, :default=, :default_proc, :default_proc=,
          :fetch_values, :index, :dig, :slice,
          :key, :each_key,
          :each_value, :values_at, :fetch_values
      end

      include CommonMethods
      extend Delegations
    end
  end
end
