require "trailblazer/option"

# TODO: mark/make all but mutable_options as frozen.
# The idea of Context is to have a generic, ordered read/write interface that
# collects mutable runtime-computed data while providing access to compile-time
# information.
# The runtime-data takes precedence over the class data.
module Trailblazer
  # Holds local options (aka `mutable_options`) and "original" options from the "outer"
  # activity (aka wrapped_options).
  # only public creator: Build
  # :data object:
  module Context
    require "trailblazer/context/container"
    require "trailblazer/context/container/with_aliases"

    module_function

    def for_circuit(wrapped_options, mutable_options, (_, flow_options), **)
      build(wrapped_options, mutable_options, **flow_options)
    end

    def build(wrapped_options, mutable_options, **flow_options)
      klass = container_class(**flow_options)
      klass.new(wrapped_options, mutable_options, **flow_options)
    end

    def container_class(default = Container, with_aliases = Container::WithAliases, **flow_options)
      return with_aliases if flow_options.key?(:context_alias)
      return default
    end
  end

  def self.Context(wrapped_options, mutable_options = {})
    Context.build(wrapped_options, mutable_options)
  end
end
