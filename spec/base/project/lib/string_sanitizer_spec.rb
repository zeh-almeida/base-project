require 'rails_helper'

RSpec.describe StringSanitizer do
  include StringSanitizer

  describe '#remove_punctuation' do
    it 'should be empty if invalid' do
      expect(remove_punctuation('')).to eq('')
    end

    it 'should remove all non alphanumeric' do
      value = get_random_string
      expect(remove_punctuation(value)).to eq(value.gsub(/[^a-zA-Z0-9]+/, ''))
    end
  end

  describe '#mask_phone' do
    it 'should be empty if invalid' do
      expect(mask_phone('')).to eq('')
    end

    it 'should mask 8 digits' do
      value = FFaker.numerify('########')
      expect(mask_phone(value)).to eq("#{value[0...4]}-#{value[4...8]}")
    end

    it 'should mask 9 digits' do
      value = FFaker.numerify('#########')
      expect(mask_phone(value)).to eq("#{value[0...3]}-#{value[3...6]}-#{value[6...9]}")
    end

    it 'should mask 10 digits' do
      value = FFaker.numerify('##########')
      expect(mask_phone(value)).to eq("(#{value[0...2]}) #{value[2...6]}-#{value[6...10]}")
    end

    it 'should mask 11 digits' do
      value = FFaker.numerify('###########')
      expect(mask_phone(value)).to eq("(#{value[0...2]}) #{value[2...5]}-#{value[5...8]}-#{value[8...11]}")
    end

    it 'should mask 12 digits' do
      value = FFaker.numerify('############')
      expect(mask_phone(value)).to eq("+#{value[0...2]} (#{value[2...4]}) #{value[4...8]}-#{value[8...12]}")
    end

    it 'should mask 13 digits' do
      value = FFaker.numerify('#############')
      expect(mask_phone(value)).to eq("+#{value[0...2]} (#{value[2...4]}) #{value[4...7]}-#{value[7...10]}-#{value[10...13]}")
    end

    it 'should return parameter if longer than 13 digits' do
      value = FFaker.numerify('##############')
      expect(mask_phone(value)).to eq(value)
    end

    it 'should return parameter if shorter than 8 digits' do
      value = FFaker.numerify('##############')
      expect(mask_phone(value)).to eq(value)
    end
  end

  describe '#parse_phone' do
    it 'should be empty if invalid' do
      expect(parse_phone('', '')).to eq('')
    end

    it 'should parse 8 or 9 digits' do
      base_number = FFaker.numerify('####')
      value = FFaker.numerify('#########')
      expect(parse_phone(value, base_number)).to eq("#{base_number[0, 4]}#{value}")
    end

    it 'should parse 10 or 11 digits' do
      base_number = FFaker.numerify('####')
      value = FFaker.numerify('###########')
      expect(parse_phone(value, base_number)).to eq("#{base_number[0, 2]}#{value}")
    end

    it 'should parse 12 or 13 digits' do
      base_number = FFaker.numerify('####')
      value = FFaker.numerify('#############')
      expect(parse_phone(value, base_number)).to eq(value)
    end

    it 'should be empty if longer than 13 digits' do
      value = FFaker.numerify('##############')
      expect(parse_phone(value, '')).to eq('')
    end

    it 'should be empty if shorter than 8 digits' do
      value = FFaker.numerify('##############')
      expect(parse_phone(value, '')).to eq('')
    end
  end

  describe '#mask_cep' do
    it 'should be empty if invalid' do
      expect(mask_cep('')).to eq('')
    end

    it 'should parse to 8 digits if longer' do
      value = FFaker.numerify('#############')
      expect(mask_cep(value)).to eq("#{value[0...5]}-#{value[5...8]}")
    end

    it 'should parse if 8 digits' do
      value = FFaker.numerify('########')
      expect(mask_cep(value)).to eq("#{value[0...5]}-#{value[5...8]}")
    end

    it 'should be empty if less than 8 characters' do
      value = FFaker.numerify('######')
      expect(mask_cep(value)).to eq('')
    end
  end

  def get_random_string
    chars = "abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789_-!@#$%*()+=[]{}\\~\|`.,<>?/;:ç"
    (0...15).collect { chars[rand(chars.length)].chr }.join
  end
end
