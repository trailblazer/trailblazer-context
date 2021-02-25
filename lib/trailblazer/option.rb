module Trailblazer
  class Option
    # A call implementation invoking `proc.(*args)` and plainly forwarding all arguments.
    # Override this for your own step strategy (see KW#call!).
    # @private
    def self.call!(proc, *args, keyword_arguments: {}, **, &block)
      # {**keyword_arguments} gets removed automatically if it's an empty hash.
      # DISCUSS: is this a good practice?
      proc.(*args, **keyword_arguments, &block)
    end

    # Note that both #evaluate_callable and #evaluate_method drop most of the args.
    # If you need those, override this class.
    # @private
    def self.evaluate_callable(proc, *args, **options, &block)
      call!(proc, *args, **options, &block)
    end

    # Make the context's instance method a "lambda" and reuse #call!.
    # @private
    def self.evaluate_method(proc, *args, exec_context: raise("No :exec_context given."), **options, &block)
      call!(exec_context.method(proc), *args, **options, &block)
    end

    # Generic builder for a callable "option".
    # @param call_implementation [Class, Module] implements the process of calling the proc
    #   while passing arguments/options to it in a specific style (e.g. kw args, step interface).
    # @return [Proc] when called, this proc will evaluate its option (at run-time).
    def self.build(proc)
      if proc.is_a? Symbol
        ->(*args, **kws, &block) { Option.evaluate_method(proc, *args, **kws, &block) }
      else
        ->(*args, **kws, &block) {
          Option.evaluate_callable(proc, *args, **kws, &block) }
      end
    end

    def self.KW(proc)
      raise "The `Option::KW()` method has been removed in trailblazer-context-0.4.
Please use `Option(task, keyword_arguments: {...})` instead. Check https://trailblazer.to/2.1/docs/trailblazer.html#trailblazer-context-option"
    end
  end
  # @note This might go to trailblazer-args along with `Context` at some point.
  def self.Option(proc)
    Option.build(proc)
  end
end
