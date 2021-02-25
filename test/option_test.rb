require "test_helper"

class OptionTest < Minitest::Spec
  def assert_result(result, block = nil)
    _(result).must_equal([{a: 1}, 2, {b: 3}, block])

    _(positional.inspect).must_equal %({:a=>1})
    _(keywords.inspect).must_equal %({:a=>2, :b=>3})
  end

  # it "what" do
  #   ctx = {params: 1}
  #   tmp_options = {constant: Object, model: Module}

  #   builder = Class.new do
  #     def builder(ctx, constant:, model:, **)
  #       raise model.inspect
  #     end
  #   end.new

  #   circuit_options = {exec_context: builder}

  #   # Trailblazer::Option(:builder, ).(ctx, tmp_options, **circuit_options.merge(keyword_arguments: tmp_options))  # calls {def default_contract!(options, constant:, model:, **)}
  #   Trailblazer::Option(:builder, ).(ctx, **circuit_options.merge(keyword_arguments: tmp_options))  # calls {def default_contract!(options, constant:, model:, **)}
  # end

  describe "positional and kws" do
    class Step
      def with_positional_and_keywords(options, a: nil, **more_options, &block)
        [options, a, more_options, block]
      end
    end

    WITH_POSITIONAL_AND_KEYWORDS = ->(options, a: nil, **more_options, &block) do
      [options, a, more_options, block]
    end

    class WithPositionalAndKeywords
      def self.call(options, a: nil, **more_options, &block)
        [options, a, more_options, block]
      end
    end

    let(:positional) { {a: 1} }
    let(:keywords)   { {a: 2, b: 3} }

    let(:block) { ->(*) { snippet } }

    describe ":method" do
      let(:option) { Trailblazer::Option(:with_positional_and_keywords) }

      it "passes through all args" do
        step = Step.new

        # positional = { a: 1 }
        # keywords   = { a: 2, b: 3 }
        assert_result option.(positional, keyword_arguments: keywords, exec_context: step)
      end

      it "allows passing a block, too" do
        step = Step.new

        assert_result option.(positional, keyword_arguments: keywords, exec_context: step, &block), block
      end
    end

    describe "lambda" do
      let(:option) { Trailblazer::Option(WITH_POSITIONAL_AND_KEYWORDS) }

      it "-> {} lambda" do
        assert_result option.(positional, **{keyword_arguments: keywords})
      end

      it "allows passing a block, too" do
        assert_result option.(positional, **{keyword_arguments: keywords}, &block), block
      end

      it "doesn't mind :exec_context" do
        assert_result option.(positional, keyword_arguments: keywords, exec_context: "bogus")
      end
    end

    describe "Callable" do
      let(:option) { Trailblazer::Option(WithPositionalAndKeywords) }

      it "passes through all args" do
        assert_result option.(positional, keyword_arguments: keywords, exec_context: nil)
      end

      it "allows passing a block, too" do
        assert_result option.(positional, keyword_arguments: keywords, exec_context: nil, &block), block
      end
    end
  end

  describe "positionals" do
    def assert_result_pos(result)
      if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.7.0")
        _(result).must_equal([1, 2, [3, 4]])
        _(positionals).must_equal [1, 2, 3, 4]
      else
        _(result).must_equal([1, 2, [3, 4, {}]])
        _(positionals).must_equal [1, 2, 3, 4]
      end
    end

    # In Ruby < 3.0, {*args} will grab both positionals and keyword arguments.
    class Step
      def with_positionals(a, b, *args)
        [a, b, args]
      end
    end

    WITH_POSITIONALS = ->(a, b, *args) do
      [a, b, args]
    end

    class WithPositionals
      def self.call(a, b, *args)
        [a, b, args]
      end
    end

    let(:positionals) { [1, 2, 3, 4] }

    it ":method" do
      step = Step.new

      option = Trailblazer::Option(:with_positionals)

      assert_result_pos option.(*positionals, exec_context: step)
    end

    it "-> {} lambda" do
      option = Trailblazer::Option(WITH_POSITIONALS)

      assert_result_pos option.(*positionals, exec_context: "something")
    end

    it "callable" do
      option = Trailblazer::Option(WithPositionals)

      assert_result_pos option.(*positionals, exec_context: "something")
    end
  end

end
