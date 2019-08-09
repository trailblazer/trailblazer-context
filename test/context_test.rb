require "test_helper"
require "trailblazer/container_chain"

class ArgsTest < Minitest::Spec
  Context = Trailblazer::Context

  let(:immutable) { {repository: "User"} }

  let(:ctx) { Trailblazer::Context(immutable) }

  it do
    ctx = Trailblazer::Context(immutable)

    # it {  }
    #-
    # options[] and options[]=
    ctx[:model]    = Module
    ctx[:contract] = Integer
    ctx[:model]   .must_equal Module
    ctx[:contract].must_equal Integer

    # it {  }
    immutable.inspect.must_equal %({:repository=>\"User\"})
  end

  it "allows false/nil values" do
    ctx["x"] = false
    ctx["x"].must_equal false

    ctx["x"] = nil
    assert_nil ctx["x"]
  end

  #- #to_hash
  it do
    ctx = Trailblazer::Context(immutable)

    # it {  }
    ctx.to_hash.must_equal(repository: "User")

    # last added has precedence.
    # only symbol keys.
    # it {  }
    ctx[:a] = Symbol
    ctx["a"] = String

    ctx.to_hash.must_equal(repository: "User", a: String)
  end

  describe "#merge" do
    it do
      ctx = Trailblazer::Context(immutable)

      merged = ctx.merge(current_user: Module)

      merged.to_hash.must_equal(repository: "User", current_user: Module)
      ctx.to_hash.must_equal(repository: "User")
    end
  end

  #-
  it do
    immutable = {repository: "User", model: Module, current_user: Class}

    Trailblazer::Context(immutable) do |_original, mutable|
      mutable
    end
  end
end

class ContextWithIndifferentAccessTest < Minitest::Spec
  it do
    flow_options    = {}
    circuit_options = {}

    immutable       = {model: Object, "policy" => Hash}

    ctx = Trailblazer::Context.for(immutable, [immutable, flow_options], circuit_options)

    ctx[:model].must_equal Object
    ctx["model"].must_equal Object
    ctx[:policy].must_equal Hash
    ctx["policy"].must_equal Hash

    ctx["contract.default"] = Module
    ctx["contract.default"].must_equal Module
    ctx[:"contract.default"].must_equal Module

    assert_nil ctx[nil]
    assert_nil ctx[true]
    assert_nil ctx[false]

# key?
    ctx.key?("____contract.default").must_equal false
    ctx.key?("contract.default").must_equal true
    ctx.key?(:"contract.default").must_equal true
    ctx.key?(nil).must_equal false
    ctx.key?(true).must_equal false
    ctx.key?(false).must_equal false

# context in context
    ctx2 = Trailblazer::Context.for(ctx, [ctx, flow_options], circuit_options)

    ctx2[:model].must_equal Object
    ctx2["model"].must_equal Object

    ctx2["contract.default"] = Class
    ctx2["contract.default"].must_equal Class
    ctx2[:"contract.default"].must_equal Class

    assert_nil ctx2[nil]
    assert_nil ctx2[true]
    assert_nil ctx2[false]

# key?
    ctx2.key?("contract.default").must_equal true
    ctx2.key?(:"contract.default").must_equal true
    ctx2.key?("model").must_equal true
    ctx2.key?(nil).must_equal false
    ctx2.key?(true).must_equal false
    ctx2.key?(false).must_equal false

# wrapped ctx doesn't change
    ctx["contract.default"].must_equal Module
    ctx[:"contract.default"].must_equal Module


    ctx3 = ctx.merge("result" => false)

    ctx3["contract.default"].must_equal Module
    ctx3[:"contract.default"].must_equal Module
    ctx3["result"].must_equal false
    ctx3[:result].must_equal false

    assert_nil ctx3[nil]
    assert_nil ctx3[true]
    assert_nil ctx3[false]

# key?
    ctx3.key?("result").must_equal true
    ctx3.key?(:result).must_equal true
    ctx3.key?(nil).must_equal false
    ctx3.key?(true).must_equal false
    ctx3.key?(false).must_equal false
  end
end

# TODO: test overriding Context.implementation.
