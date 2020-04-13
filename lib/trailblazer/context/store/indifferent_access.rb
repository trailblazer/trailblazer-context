require "hashie"

module Trailblazer
  module Context
    module Store
      # Simple yet indifferently accessible hash store, used as replica in Context::Container.
      # It maintains cache for multiple hashes (wrapped_options, mutable_options etc).
      class IndifferentAccess < Hash
        include Hashie::Extensions::IndifferentAccess

        def initialize(*hashes)
          hashes.each do |hash|
            hash.each do |key, value|
              self[key] = value
            end
          end
        end

        # Override of Hashie::Extensions::IndifferentAccess#indifferent_value
        # to not do deep indifferent access conversion.
        # DISCUSS: Should we make this configurable ?
        def indifferent_value(value)
          value
        end

        # Override of Hashie::Extensions::IndifferentAccess#convert_key
        # to store keys as Symbol by default instead of String.
        # Why ? We need to pass `ctx` as keyword arguments most of the time.
        def convert_key(key)
          return key if Symbol === key 
          String === key ? key.to_sym : key
        end
      end
    end
  end
end
