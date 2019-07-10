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
    immutable = {model: Object}

    ctx = Trailblazer::Context::IndifferentAccess.new(immutable, {})

    ctx[:model].must_equal Object
    ctx["model"].must_equal Object

    ctx["contract.default"] = Module
    ctx["contract.default"].must_equal Module
    ctx[:"contract.default"].must_equal Module

# context in context
    Trailblazer::Context.for(ctx)
  end

  # key?
  # after #merge
end
