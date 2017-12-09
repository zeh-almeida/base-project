require 'rails_helper'

RSpec.describe ConsoleSay do
  include ConsoleSay

  describe '#say' do
    it 'should say a text when ran' do
      message = get_string
      expect { say(message) }.to output(base_message(message)).to_stdout
    end
  end

  describe '#say_with_time' do
    it 'should say text with with block when ran' do
      message = get_string
      expect { say_with_time(message) { 2 + 2 } }.to output(/.*\s*->\s(\d*).(\d*)s/).to_stdout
    end
  end

  def get_string
    message = Array.new(rand(10..20)) { [*'A'..'Z', *'0'..'9'].sample }.join
  end

  def base_message(text)
    "-- #{text}\n"
  end
end
