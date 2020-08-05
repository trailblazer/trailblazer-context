module Trailblazer
  module Context
    class Container
      # Extension to replace Context::Container writers with aliased writers.
      # It'll mutate the well known `@mutable_options` with only original keys and
      # `@replica` with both orignal and aliased keys
      class WithAliases < Container
        def initialize(wrapped_options, mutable_options, aliases:, replica_class:, **)
          @wrapped_options  = wrapped_options
          @mutable_options  = mutable_options

          # { "contract.default" => :contract, "result.default" => :result }
          @aliases          = aliases

          @replica_class    = replica_class
          @replica          = initialize_replica_store
        end

        def inspect
          %{#<Trailblazer::Context::Container::WithAliases wrapped_options=#{@wrapped_options} mutable_options=#{@mutable_options} aliases=#{@aliases}>}
        end

        # @public
        def aliased_writer(key, value)
          _key, _alias = alias_mapping_for(key)

          @mutable_options[_key] = value
          @replica[_key]         = value
          @replica[_alias]       = value if _alias
        end
        alias_method :[]=, :aliased_writer

        # @public
        def aliased_delete(key)
          _key, _alias = alias_mapping_for(key)

          @mutable_options.delete(_key)
          @replica.delete(_key)
          @replica.delete(_alias) if _alias
        end
        alias_method :delete, :aliased_delete

        # @public
        def aliased_merge(other_hash)
          # other_hash could have aliases and we don't want to store them in @mutable_options.
          _other_hash = replace_aliases_with_original_keys(other_hash)

          options = { aliases: @aliases, replica_class: @replica_class }
          self.class.new(@wrapped_options, @mutable_options.merge(_other_hash), **options)
        end
        alias_method :merge, :aliased_merge

        # Returns key and it's mapped alias. `key` could be an alias too.
        #
        # aliases => { "contract.default" => :contract, "result.default"=>:result }
        # key, _alias = alias_mapping_for(:contract)
        # key, _alias = alias_mapping_for("contract.default")
        #
        # @public
        def alias_mapping_for(key)
          # when key has an alias
          return [ key, @aliases[key] ] if @aliases.key?(key)

          # when key is an alias
          return [ @aliases.key(key), key ] if @aliases.value?(key)

          # when there is no alias
          return [ key, nil ]
        end

        private

        # Maintain aliases in `@replica` to make ctx actions faster™
        def initialize_replica_store
          replica = @replica_class.new([ @wrapped_options, @mutable_options ])

          @aliases.each do |original_key, _alias|
            replica[_alias] = replica[original_key] if replica.key?(original_key)
          end

          replica
        end

        # Replace aliases from `hash` with their orignal keys.
        # This is used while doing a `merge` which initializes new Container
        # with original keys and their aliases.
        def replace_aliases_with_original_keys(hash)
          # DISCUSS: Better way to check for alias presence in `hash`
          return hash unless (hash.keys & @aliases.values).any?

          _hash = hash.dup

          @aliases.each do |original_key, _alias|
            _hash[original_key] = _hash.delete(_alias) if _hash.key?(_alias)
          end

          return _hash
        end 
      end
    end
  end
end
