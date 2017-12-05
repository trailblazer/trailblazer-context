# Trailblazer-context

_Argument-specific data structures for Trailblazer._

This gem provides data structures needed across `Activity`, `Workflow` and `Operation`, such as the following.

* `Trailblazer::Context` implements the so-called `options` hash that is passed between steps and implements the keyword arguments.
* `Trailblazer::Option` is often used to wrap an option at compile-time and `call` it at runtime, which allows to have the common `-> ()`, `:method` or `Callable` pattern used for most options.
* `Trailblazer::ContainerChain` to implement chained lookups of properties and allow including containers such as `Dry::Container` in this chain. This is experimental.
