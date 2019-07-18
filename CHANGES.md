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
