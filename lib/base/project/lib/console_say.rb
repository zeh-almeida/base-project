module ConsoleSay
  extend self

  def say(message, subitem = false)
    puts "#{subitem ? '   ->' : '--'} #{message}"
  end

  def say_with_time(message)
    say(message)

    time = Benchmark.measure { result = yield }

    time_message = '%.4fs' % time.real
    say(time_message, :subitem)
    time_message
  end
end
