# 0.3.1

* Even though this is a patch version, but it contains major changes.
* `to_hash` speed improvement - Same-ish as `Hash#to_hash`.
* Maintains replica for faster access and copy actions.
* Support all other `Hash` features (find, dig, collect etc) on `ctx` object.
* Namespace context related options within `flow_options`. (`{ flow_options: { context_options: { aliases: {}, ** } } }`).
* Add `Trailblazer::Context()` API with standard default container & replica class.

# 0.3.0
* Add support for ruby 2.7
* Drop support for ruby 2.0

# 0.2.0

* Added `Context::IndifferentAccess`.
* Added `Context::Aliasing`.
* `Context.for_circuit` is not the authorative builder for creating a context.

# 0.1.5

* `Context.build` allows quickly building a Context without requiring the circuit interface.

# 0.1.4

* Fix the `IndifferentAccess` name lookup. Since we can't convert all keys to symbols internally (not every options structure has `collect`) we need to have a lookup chain.

# 0.1.3

* Introduce `Context::IndifferentAccess` which converts all keys to symbol. This, in turn, allows to use both string and symbol keys everywhere. Currently, the implementation is set via the global method `Context.implementation` and defaults to the new `IndifferentAccess`.

# 0.1.2

* More meaningful error message: "No :exec_context given.".

# 0.1.1

* `Option.( *args, &block )` now passes through the block to the option call.

# 0.1.0

* Extracted from `trailblazer-activity`, here it comes.
