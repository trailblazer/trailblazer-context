require "test_helper"

class OptionTest < Minitest::Spec
  def assert_result(result, block=nil)
    result.must_equal( [{:a=>1}, 2, {:b=>3}, block] )

      positional.inspect.must_equal %{{:a=>1}}
      keywords.inspect.must_equal %{{:a=>2, :b=>3}}
  end

  describe "positional and kws" do
    class Step
      def with_positional_and_keywords(options, a:nil, **more_options, &block)
        [ options, a, more_options, block ]
      end
    end

    WITH_POSITIONAL_AND_KEYWORDS = ->(options, a:nil, **more_options, &block) do
      [ options, a, more_options, block ]
    end

    class WithPositionalAndKeywords
      def self.call(options, a:nil, **more_options, &block)
        [ options, a, more_options, block ]
      end
    end

    let(:positional) { { a: 1 } }
    let(:keywords)   { { a: 2, b: 3 } }

    let(:block)  { ->(*) { snippet } }

    describe ":method" do
      let(:option) { Trailblazer::Option(:with_positional_and_keywords) }

      it "passes through all args" do
        step = Step.new

        # positional = { a: 1 }
        # keywords   = { a: 2, b: 3 }
        assert_result option.( positional, keywords, { exec_context: step } )
      end

      it "allows passing a block, too" do
        step  = Step.new

        assert_result option.( positional, keywords, { exec_context: step }, &block ), block
      end
    end

    describe "lambda" do
      let(:option) { Trailblazer::Option(WITH_POSITIONAL_AND_KEYWORDS) }

      it "-> {} lambda" do
        assert_result option.( positional, keywords, {} )
      end

      it "allows passing a block, too" do
        assert_result option.( positional, keywords, {}, &block ), block
      end

      it "doesn't mind :exec_context" do
        assert_result option.( positional, keywords, { exec_context: "bogus" } )
      end
    end

    describe "Callable" do
      let(:option) { Trailblazer::Option(WithPositionalAndKeywords) }

      it "passes through all args" do
        assert_result option.( positional, keywords, { exec_context: nil } )
      end

      it "allows passing a block, too" do
        assert_result option.( positional, keywords, { exec_context: nil }, &block ), block
      end
    end
  end

  describe "positionals" do
    def assert_result_pos(result)
      result.must_equal( [1,2, [3, 4]] )
      positionals.must_equal [1,2, 3, 4]
    end

    class Step
      def with_positionals(a, b, *args)
        [ a, b, args ]
      end
    end

    WITH_POSITIONALS = ->(a, b, *args) do
      [ a, b, args ]
    end

    class WithPositionals
      def self.call(a, b, *args)
        [ a, b, args ]
      end
    end

    let(:positionals) { [1, 2, 3, 4] }

    it ":method" do
      step = Step.new

      option = Trailblazer::Option(:with_positionals)

      assert_result_pos option.( *positionals, { exec_context: step } )
    end

    it "-> {} lambda" do
      option = Trailblazer::Option(WITH_POSITIONALS)

      assert_result_pos option.( *positionals, { exec_context: "something" } )
    end

    it "callable" do
      option = Trailblazer::Option(WithPositionals)

      assert_result_pos option.( *positionals, { exec_context: "something" } )
    end
  end

  describe "Option::KW" do
    def assert_result_kws(result)
      result.must_equal( [{:a=>1, :b=>2, :c=>3}, 1, 2, {:c=>3}] )
    end

    class Step
      def with_kws(options, a:nil, b:nil, **rest)
        [ options, a, b, rest ]
      end
    end

    module Task
      def self.with_kws(options, a:nil, b:nil, **rest)
        [ options, a, b, rest ]
      end
    end

    WITH_KWS = ->(options, a:nil, b:nil, **rest) do
      [ options, a, b, rest ]
    end

    class WithKWs
      def self.call(options, a:nil, b:nil, **rest)
        [ options, a, b, rest ]
      end
    end

    let(:options) { { a: 1, b: 2, c: 3 } }

    it ":method" do
      step = Step.new

      option = Trailblazer::Option::KW(:with_kws)

      assert_result_kws option.( options, { exec_context: step } )
    end

    it "Method instance" do
      option = Trailblazer::Option::KW(Task.method(:with_kws))

      assert_result_kws option.( options, { } )
    end

    it "-> {} lambda" do
      option = Trailblazer::Option::KW(WITH_KWS)

      assert_result_kws option.( options, { } )
    end

    it "lambda ignores :exec_context" do
      option = Trailblazer::Option::KW(WITH_KWS)

      assert_result_kws option.( options, { exec_context: "something" } )
    end

    it "callable" do
      option = Trailblazer::Option::KW(WithKWs)

      assert_result_kws option.( options, { } )
    end
  end
end
