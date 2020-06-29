require "test_helper"
require "trailblazer/container_chain"

class ArgsTest < Minitest::Spec
  let(:immutable) { {repository: "User"} }

  let(:ctx) { Trailblazer::Context(immutable) }

  it do
    ctx = Trailblazer::Context(immutable)

    # it {  }
    #-
    # options[] and options[]=
    ctx[:model]    = Module
    ctx[:contract] = Integer
    _(ctx[:model])   .must_equal Module
    _(ctx[:contract]).must_equal Integer

    # it {  }
    _(immutable.inspect).must_equal %({:repository=>\"User\"})
  end

  it "allows false/nil values" do
    ctx["x"] = false
    _(ctx["x"]).must_equal false

    ctx["x"] = nil
    assert_nil ctx["x"]
  end

  #- #to_hash
  it do
    ctx = Trailblazer::Context(immutable)

    # it {  }
    _(ctx.to_hash).must_equal(repository: "User")

    # last added has precedence.
    # only symbol keys.
    # it {  }
    ctx[:a] = Symbol
    ctx["a"] = String

    _(ctx.to_hash).must_equal(repository: "User", a: String)
  end

  describe "#merge" do
    it do
      ctx = Trailblazer::Context(immutable)

      merged = ctx.merge(current_user: Module)

      _(merged.to_hash).must_equal(repository: "User", current_user: Module)
      _(ctx.to_hash).must_equal(repository: "User")
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

    ctx = Trailblazer::Context.for_circuit(immutable, {}, [immutable, flow_options], **circuit_options)

    _(ctx[:model]).must_equal Object
    _(ctx["model"]).must_equal Object
    _(ctx[:policy]).must_equal Hash
    _(ctx["policy"]).must_equal Hash

    ctx["contract.default"] = Module
    _(ctx["contract.default"]).must_equal Module
    _(ctx[:"contract.default"]).must_equal Module

# key?
    _(ctx.key?("____contract.default")).must_equal false
    _(ctx.key?("contract.default")).must_equal true
    _(ctx.key?(:"contract.default")).must_equal true

# context in context
    ctx2 = Trailblazer::Context.for_circuit(ctx, {}, [ctx, flow_options], **circuit_options)

    _(ctx2[:model]).must_equal Object
    _(ctx2["model"]).must_equal Object

    ctx2["contract.default"] = Class
    _(ctx2["contract.default"]).must_equal Class
    _(ctx2[:"contract.default"]).must_equal Class

# key?
    _(ctx2.key?("contract.default")).must_equal true
    _(ctx2.key?(:"contract.default")).must_equal true
    _(ctx2.key?("model")).must_equal true

# wrapped ctx doesn't change
    _(ctx["contract.default"]).must_equal Module
    _(ctx[:"contract.default"]).must_equal Module


    ctx3 = ctx.merge("result" => false)

    _(ctx3["contract.default"]).must_equal Module
    _(ctx3[:"contract.default"]).must_equal Module
    _(ctx3["result"]).must_equal false
    _(ctx3[:result]).must_equal false
    _(ctx3.key?("result")).must_equal true
    _(ctx3.key?(:result)).must_equal true
  end

  it "Aliasable" do
    flow_options    = {context_alias: {"contract.default" => :contract, "result.default"=>:result, "trace.stack" => :stack}}
    circuit_options = {}

    immutable       = {model: Object, "policy" => Hash}

    ctx = Trailblazer::Context.for_circuit(immutable, {}, [immutable, flow_options], **circuit_options)

    _(ctx[:model]).must_equal Object
    _(ctx["model"]).must_equal Object
    _(ctx[:policy]).must_equal Hash
    _(ctx["policy"]).must_equal Hash

    ctx["contract.default"] = Module
    _(ctx["contract.default"]).must_equal Module
    _(ctx[:"contract.default"]).must_equal Module

    # alias
    assert_nil ctx[:result]
    assert_nil ctx["result"]

    _(ctx[:contract]).must_equal Module

    assert_nil ctx[:stack]

  # Set an aliased property via setter
    ctx["trace.stack"] = Object
    _(ctx[:stack]).must_equal Object
    _(ctx["trace.stack"]).must_equal Object

# key?
    _(ctx.key?("____contract.default")).must_equal false
    _(ctx.key?("contract.default")).must_equal true
    _(ctx.key?(:"contract.default")).must_equal true
    _(ctx.key?(:contract)).must_equal true
    _(ctx.key?(:result)).must_equal false
    _(ctx.key?(:stack)).must_equal true
    _(ctx.key?("trace.stack")).must_equal true
    _(ctx.key?(:"trace.stack")).must_equal true

# to_hash
    _(ctx.to_hash).must_equal(:model=>Object, :policy=>Hash, :"contract.default"=>Module, :"trace.stack"=>Object, :contract=>Module, :stack=>Object)

# context in context
    ctx2 = Trailblazer::Context.for_circuit(ctx, {}, [ctx, flow_options], **circuit_options)

    _(ctx2.key?("____contract.default")).must_equal false
    _(ctx2.key?("contract.default")).must_equal true
    _(ctx2.key?(:"contract.default")).must_equal true
    _(ctx2.key?(:contract)).must_equal true
    _(ctx2.key?(:result)).must_equal false
    _(ctx2.key?("result.default")).must_equal false
    _(ctx2.key?(:stack)).must_equal true
    _(ctx2.key?("trace.stack")).must_equal true
    _(ctx2.key?(:"trace.stack")).must_equal true

  # Set aliased in new context via setter
    ctx2["result.default"] = Class

    _(ctx2[:result]).must_equal Class
    _(ctx2[:"result.default"]).must_equal Class

    _(ctx2.key?("result.default")).must_equal true
    _(ctx2.key?(:"result.default")).must_equal true
    _(ctx2.key?(:result)).must_equal true

    # todo: TEST flow_options={context_class: SomethingElse}
  end

  it ".build provides default args" do
    immutable       = {model: Object, "policy.default" => Hash}

  # {Aliasing#initialize}
    ctx = Trailblazer::Context::IndifferentAccess.new(immutable, {}, context_alias: {"policy.default" => :policy})

    _(ctx[:model]).must_equal Object
    _(ctx["model"]).must_equal Object
    _(ctx[:policy]).must_equal Hash

    ctx2 = ctx.merge(result: :success)


    _(ctx2[:model]).must_equal Object
    _(ctx2["model"]).must_equal Object
    _(ctx2[:policy]).must_equal Hash
    _(ctx2[:result]).must_equal :success
  end
end

# TODO: test overriding Context.implementation.
