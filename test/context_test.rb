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
    _(ctx.inspect).must_equal %{#<Trailblazer::Context::Container wrapped_options={:repository=>\"User\"} mutable_options={:model=>Module, :contract=>Integer}>}
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

      _(merged.class).must_equal(Trailblazer::Context::Container)
      _(merged.to_hash).must_equal(repository: "User", current_user: Module)
      _(ctx.to_hash).must_equal(repository: "User")
    end
  end

  describe "Enumerable behaviour" do
    it { _(ctx.each.to_a).must_equal [[:repository, "User"]] }
    it { _(ctx.find{ |k, _| k == :repository }).must_equal [:repository, "User"] }
    it { _(ctx.inject([]){ |r, (k, _)| r << k}).must_equal [:repository] }
  end

  #- #decompose
  it do
    immutable = {repository: "User", model: Module, current_user: Class}
    mutable   = {error: RuntimeError}

    _([immutable, mutable]).must_equal Trailblazer::Context(immutable, mutable).decompose
  end
end

class ContextWithIndifferentAccessTest < Minitest::Spec
  it do
    flow_options    = {
      context_options: {
        container_class: Trailblazer::Context::Container,
        replica_class: Trailblazer::Context::Store::IndifferentAccess
      }
    }

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

# delete
    ctx[:model] = Object
    ctx.delete 'model'

    _(ctx.key?(:model)).must_equal false
    _(ctx.key?("model")).must_equal false

    ctx3 = ctx.merge("result" => false)

    _(ctx3["contract.default"]).must_equal Module
    _(ctx3[:"contract.default"]).must_equal Module
    _(ctx3["result"]).must_equal false
    _(ctx3[:result]).must_equal false
    _(ctx3.key?("result")).must_equal true
    _(ctx3.key?(:result)).must_equal true
  end

  it "Aliasable" do
    flow_options    = {
      context_options: {
        container_class: Trailblazer::Context::Container::WithAliases,
        replica_class: Trailblazer::Context::Store::IndifferentAccess,
        aliases: { "contract.default" => :contract, "result.default"=>:result, "trace.stack" => :stack }
      }
    }

    circuit_options = {}

    immutable       = {model: Object, "policy" => Hash}

    ctx = Trailblazer::Context.for_circuit(immutable, {}, [immutable, flow_options], **circuit_options)
    _(ctx.class).must_equal(Trailblazer::Context::Container::WithAliases)

    _(ctx.inspect).must_equal %{#<Trailblazer::Context::Container::WithAliases wrapped_options={:model=>Object, \"policy\"=>Hash} mutable_options={} aliases={\"contract.default\"=>:contract, \"result.default\"=>:result, \"trace.stack\"=>:stack}>}

    _(ctx.to_hash).must_equal(:model=>Object, :policy=>Hash)

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
    _(ctx['contract']).must_equal Module

    assert_nil ctx[:stack]
    assert_nil ctx['stack']

  # Set an aliased property via setter
    ctx["trace.stack"] = Object
    _(ctx[:stack]).must_equal Object
    _(ctx["stack"]).must_equal Object
    _(ctx["trace.stack"]).must_equal Object

  # Set an aliased property with merge
    ctx["trace.stack"] = String
    merged = ctx.merge(stack: Integer)

    _(merged.class).must_equal(Trailblazer::Context::Container::WithAliases)
    _(merged.to_hash).must_equal(:model=>Object, :policy=>Hash, :contract=>Module, :"contract.default"=>Module, :stack=>Integer, :"trace.stack"=>Integer)

# key?
    _(ctx.key?("____contract.default")).must_equal false
    _(ctx.key?("contract.default")).must_equal true
    _(ctx.key?(:"contract.default")).must_equal true
    _(ctx.key?(:contract)).must_equal true
    _(ctx.key?(:result)).must_equal false
    _(ctx.key?(:stack)).must_equal true
    _(ctx.key?("trace.stack")).must_equal true
    _(ctx.key?(:"trace.stack")).must_equal true

# delete
    ctx[:result] = Object
    ctx.delete :result

    _(ctx.key?(:result)).must_equal false
    _(ctx.key?("result")).must_equal false

    _(ctx.key?(:"result.default")).must_equal false
    _(ctx.key?("result.default")).must_equal false


# to_hash
    _(ctx.to_hash).must_equal(:model=>Object, :policy=>Hash, :contract=>Module, :"contract.default"=>Module, :stack=>String, :"trace.stack"=>String)

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

  it ".build accepts custom container class" do
    MyContainer = Class.new(Trailblazer::Context::Container) do
      def inspect
        %{#<MyContainer wrapped=#{@wrapped_options} mutable=#{@mutable_options}>}
      end
    end

    immutable = { model: Object }
    options   = { container_class: MyContainer, replica_class: Trailblazer::Context::Store::IndifferentAccess }

    ctx = Trailblazer::Context.build(immutable, {}, options)
    _(ctx.class).must_equal(MyContainer)
    _(ctx.inspect).must_equal("#<MyContainer wrapped=#{immutable} mutable={}>")

    _(ctx.to_hash).must_equal({ model: Object })

    ctx[:integer] = Integer
    _(ctx.to_hash).must_equal({ model: Object, integer: Integer })

    ctx2 = ctx.merge(float: Float)
    _(ctx2.class).must_equal(MyContainer)

    _(ctx2.to_hash).must_equal({ model: Object, integer: Integer, float: Float })
  end

  it ".build accepts custom replica class (For example, To opt out from indifferent access)" do
    MyReplica = Class.new(Hash) do
      def initialize(*containers)
        containers.each do |container|
          container.each{ |key, value| self[key] = value }
        end
      end
    end

    immutable = { model: Object }
    options   = { container_class: Trailblazer::Context::Container, replica_class: MyReplica }

    ctx = Trailblazer::Context.build(immutable, {}, options)
    ctx[:integer] = Integer

    _(ctx[:integer]).must_equal(Integer)
    _(ctx['integer']).must_be_nil
  end

  it "Context() provides default args" do
    immutable = {model: Object, "policy.default" => Hash}
    options   = {
      container_class: Trailblazer::Context::Container::WithAliases,
      aliases: { "policy.default" => :policy }
    }

    ctx = Trailblazer::Context(immutable, {}, options)

    _(ctx[:model]).must_equal Object
    _(ctx["model"]).must_equal Object
    _(ctx[:policy]).must_equal Hash

    ctx2 = ctx.merge(result: :success)


    _(ctx2[:model]).must_equal Object
    _(ctx2["model"]).must_equal Object
    _(ctx2[:policy]).must_equal Hash
    _(ctx2[:result]).must_equal :success
  end

  it "Context() throws RuntimeError if aliases are passed but container_class doesn't support it" do
    immutable = {model: Object, "policy.default" => Hash}
    options   = {
      aliases: { "policy.default" => :policy }
    }

    exception = assert_raises Trailblazer::Context::Container::UseWithAliases do
      Trailblazer::Context(immutable, {}, options)
    end

    _(exception.message).must_equal %{Pass `Trailblazer::Context::Container::WithAliases` as `container_class` while defining `aliases`}
  end
end

# TODO: test overriding Context.implementation.
