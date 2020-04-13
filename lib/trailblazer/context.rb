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

    module Extension
      autoload :Aliasing, "trailblazer/context/extension/aliasing"
    end

    module_function

    def for_circuit(wrapped_options, mutable_options, (_, flow_options), **)
      Context.build(wrapped_options, mutable_options, **flow_options)
    end

    def build(wrapped_options, mutable_options, container_class: Context::Container, **flow_options)
      if flow_options[Context::Extension::Aliasing::CONFIG_KEY]
        container_class = Class.new(container_class).prepend(Context::Extension::Aliasing)
      end

      container_class.new(wrapped_options, mutable_options, **flow_options)
    end
  end

  def self.Context(wrapped_options, mutable_options = {})
    Context.build(wrapped_options, mutable_options)
  end
end
