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

    ctx = Trailblazer::Context.for_circuit(immutable, {}, [immutable, flow_options], circuit_options)

    ctx[:model].must_equal Object
    ctx["model"].must_equal Object
    ctx[:policy].must_equal Hash
    ctx["policy"].must_equal Hash

    ctx["contract.default"] = Module
    ctx["contract.default"].must_equal Module
    ctx[:"contract.default"].must_equal Module

# key?
    ctx.key?("____contract.default").must_equal false
    ctx.key?("contract.default").must_equal true
    ctx.key?(:"contract.default").must_equal true

# context in context
    ctx2 = Trailblazer::Context.for_circuit(ctx, {}, [ctx, flow_options], circuit_options)

    ctx2[:model].must_equal Object
    ctx2["model"].must_equal Object

    ctx2["contract.default"] = Class
    ctx2["contract.default"].must_equal Class
    ctx2[:"contract.default"].must_equal Class

# key?
    ctx2.key?("contract.default").must_equal true
    ctx2.key?(:"contract.default").must_equal true
    ctx2.key?("model").must_equal true

# wrapped ctx doesn't change
    ctx["contract.default"].must_equal Module
    ctx[:"contract.default"].must_equal Module


    ctx3 = ctx.merge("result" => false)

    ctx3["contract.default"].must_equal Module
    ctx3[:"contract.default"].must_equal Module
    ctx3["result"].must_equal false
    ctx3[:result].must_equal false
    ctx3.key?("result").must_equal true
    ctx3.key?(:result).must_equal true
  end

  it "Aliasable" do
    flow_options    = {context_alias: {"contract.default" => :contract, "result.default"=>:result, "trace.stack" => :stack}}
    circuit_options = {}

    immutable       = {model: Object, "policy" => Hash}

    ctx = Trailblazer::Context.for_circuit(immutable, {}, [immutable, flow_options], circuit_options)

    ctx[:model].must_equal Object
    ctx["model"].must_equal Object
    ctx[:policy].must_equal Hash
    ctx["policy"].must_equal Hash

    ctx["contract.default"] = Module
    ctx["contract.default"].must_equal Module
    ctx[:"contract.default"].must_equal Module

    # alias
    ctx[:result].must_equal nil
    ctx["result"].must_equal nil

    ctx[:contract].must_equal Module

    ctx[:stack].must_equal nil

  # Set an aliased property via setter
    ctx["trace.stack"] = Object
    ctx[:stack].must_equal Object
    ctx["trace.stack"].must_equal Object

# key?
    ctx.key?("____contract.default").must_equal false
    ctx.key?("contract.default").must_equal true
    ctx.key?(:"contract.default").must_equal true
    ctx.key?(:contract).must_equal true
    ctx.key?(:result).must_equal false
    ctx.key?(:stack).must_equal true
    ctx.key?("trace.stack").must_equal true
    ctx.key?(:"trace.stack").must_equal true

# to_hash
    ctx.to_hash.must_equal(:model=>Object, :policy=>Hash, :"contract.default"=>Module, :"trace.stack"=>Object, :contract=>Module, :stack=>Object)

# context in context
    ctx2 = Trailblazer::Context.for_circuit(ctx, {}, [ctx, flow_options], circuit_options)

    ctx2.key?("____contract.default").must_equal false
    ctx2.key?("contract.default").must_equal true
    ctx2.key?(:"contract.default").must_equal true
    ctx2.key?(:contract).must_equal true
    ctx2.key?(:result).must_equal false
    ctx2.key?("result.default").must_equal false
    ctx2.key?(:stack).must_equal true
    ctx2.key?("trace.stack").must_equal true
    ctx2.key?(:"trace.stack").must_equal true

  # Set aliased in new context via setter
    ctx2["result.default"] = Class

    ctx2[:result].must_equal Class
    ctx2[:"result.default"].must_equal Class

    ctx2.key?("result.default").must_equal true
    ctx2.key?(:"result.default").must_equal true
    ctx2.key?(:result).must_equal true

    # todo: TEST flow_options={context_class: SomethingElse}
  end

  it ".build provides default args" do
    immutable       = {model: Object, "policy.default" => Hash}

  # {Aliasing#initialize}
    ctx = Trailblazer::Context::IndifferentAccess.new(immutable, {}, context_alias: {"policy.default" => :policy})

    ctx[:model].must_equal Object
    ctx["model"].must_equal Object
    ctx[:policy].must_equal Hash

    ctx2 = ctx.merge(result: :success)


    ctx2[:model].must_equal Object
    ctx2["model"].must_equal Object
    ctx2[:policy].must_equal Hash
    ctx2[:result].must_equal :success
  end
end

# TODO: test overriding Context.implementation.
