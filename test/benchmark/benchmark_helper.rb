require 'test_helper'
require 'benchmark/ips'

BenchmarkRepresenter = Struct.new(:benchmark, :times_slower)

Minitest::Spec.class_eval do
  def benchmark_ips(records, time: 1, warmup: 1)
    base    = records[:base]
    target  = records[:target]

    benchmark = Benchmark.ips do |x|
      x.config(time: time, warmup: warmup)

      x.report(base[:label], &base[:block])
      x.report(target[:label], &target[:block])

      x.compare!
    end

    times_slower = benchmark.data[0][:ips] / benchmark.data[1][:ips]
    BenchmarkRepresenter.new(benchmark, times_slower)
  end

  def assert_times_slower(result, threshold)
    base    = result.benchmark.data[0]
    target  = result.benchmark.data[1]

    msg = "Expected #{target[:name]} to be slower by at most #{threshold} times than #{base[:name]}, but got #{result.times_slower}"

    assert result.times_slower < threshold, msg
  end
end
