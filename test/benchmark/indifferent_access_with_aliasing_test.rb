require_relative "benchmark_helper"

describe "Context::Aliasing Performance" do
  wrapped_options = { model: Object, policy: Hash, representer: String }
  mutable_options = { write: String, read: Integer, delete: Float, merge: Symbol }

  context_alias   = { read: :reader }

  default_hash      = Hash(**wrapped_options, **mutable_options)
  aliased_hash  = Trailblazer::Context.build(wrapped_options, mutable_options, context_alias: context_alias)

  it "initialize" do
    result = benchmark_ips(
      base: { label: :initialize_default_hash, block: ->{
        Hash(**wrapped_options, **mutable_options)
      }},
      target: { label: :initialize_aliased_hash, block: ->{
        Trailblazer::Context.build(wrapped_options, mutable_options, context_alias: context_alias)
      }},
    )

    assert_times_slower result, 8
  end

  it "write" do
    result = benchmark_ips(
      base: { label: :write_to_default_hash, block: ->{ default_hash[:write] = "" } },
      target: { label: :write_to_aliased_hash, block: ->{ aliased_hash[:write] = "" } },
    )

    assert_times_slower result, 3.66
  end

  it "read" do
    result = benchmark_ips(
      base: { label: :read_from_default_hash, block: ->{ default_hash[:read] } },
      target: { label: :read_from_aliased_hash, block: ->{ aliased_hash[:reader] } },
    )

    assert_times_slower result, 1.5
  end

  it "delete" do
    result = benchmark_ips(
      base: { label: :delete_from_default_hash, block: ->{ default_hash.delete(:delete) } },
      target: { label: :delete_from_aliased_hash, block: ->{ aliased_hash.delete(:delete) } },
    )

    assert_times_slower result, 4
  end

  it "merge" do
    result = benchmark_ips(
      base: { label: :merge_from_default_hash, block: ->{ default_hash.merge(merge: :object_id) } },
      target: { label: :merge_from_aliased_hash, block: ->{ aliased_hash.merge(merge: :object_id) } },
    )

    assert_times_slower result, 8.5
  end

  it "to_hash" do
    result = benchmark_ips(
      base: { label: :default_to_hash, block: ->{ default_hash.to_hash } },
      target: { label: :aliased_to_hash, block: ->{ aliased_hash.to_hash } },
    )

    assert_times_slower result, 1.5
  end
end
