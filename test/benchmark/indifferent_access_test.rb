require_relative "benchmark_helper"

describe "Context::IndifferentAccess Performance" do
  wrapped_options = { model: Object, policy: Hash, representer: String }
  mutable_options = { write: String, read: Integer, delete: Float, merge: Symbol }
  context_options = {
    container_class: Trailblazer::Context::Container,
    replica_class: Trailblazer::Context::Store::IndifferentAccess,
  }

  default_hash      = Hash(**wrapped_options, **mutable_options)
  indifferent_hash  = Trailblazer::Context.build(wrapped_options, mutable_options, context_options)

  it "initialize" do
    result = benchmark_ips(
      base: { label: :initialize_default_hash, block: ->{
        Hash(**wrapped_options, **mutable_options)
      }},
      target: { label: :initialize_indifferent_hash, block: ->{
        Trailblazer::Context.build(wrapped_options, mutable_options, context_options)
      }},
    )

    assert_times_slower result, 3
  end

  it "read" do
    result = benchmark_ips(
      base: { label: :read_from_default_hash, block: ->{ default_hash[:read] } },
      target: { label: :read_from_indifferent_hash, block: ->{ indifferent_hash[:read] } },
    )

    assert_times_slower result, 1.4
  end

  it "unknown read" do
    result = benchmark_ips(
      base: { label: :unknown_read_from_default_hash, block: ->{ default_hash[:unknown] } },
      target: { label: :unknown_read_from_indifferent_hash, block: ->{ indifferent_hash[:unknown] } },
    )

    assert_times_slower result, 3.5
  end

  it "write" do
    result = benchmark_ips(
      base: { label: :write_to_default_hash, block: ->{ default_hash[:write] = "" } },
      target: { label: :write_to_indifferent_hash, block: ->{ indifferent_hash[:write] = "SKU-1" } },
    )

    assert_times_slower result, 2.3
  end

  it "delete" do
    result = benchmark_ips(
      base: { label: :delete_from_default_hash, block: ->{ default_hash.delete(:delete) } },
      target: { label: :delete_from_indifferent_hash, block: ->{ indifferent_hash.delete(:delete) } },
    )

    assert_times_slower result, 2.4
  end

  it "merge" do
    result = benchmark_ips(
      base: { label: :merge_from_default_hash, block: ->{ default_hash.merge(merge: :object_id) } },
      target: { label: :merge_from_indifferent_hash, block: ->{ indifferent_hash.merge(merge: :object_id) } },
    )

    assert_times_slower result, 5.55
  end

  it "to_hash" do
    result = benchmark_ips(
      base: { label: :default_to_hash, block: ->{ default_hash.to_hash } },
      target: { label: :indifferent_to_hash, block: ->{ indifferent_hash.to_hash } },
    )

    assert_times_slower result, 1.3
  end

  it "decompose" do
    result = benchmark_ips(
      base: { label: :dup_default_hash, block: ->{ default_hash.to_hash } },
      target: { label: :decompose, block: ->{ indifferent_hash.decompose } },
    )

    assert_times_slower result, 1.55
  end
end
