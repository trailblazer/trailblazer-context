# Trailblazer-context

_Argument-specific data structures for Trailblazer._

This gem provides data structures needed across `Activity`, `Workflow` and `Operation`, such as the following.

* `Trailblazer::Context` implements the so-called `options` hash that is passed between steps and implements the keyword arguments.
* `Trailblazer::ContainerChain` to implement chained lookups of properties and allow including containers such as `Dry::Container` in this chain. This is experimental.
