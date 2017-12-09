module Base::Project::Lib::StringSanitizer
  extend self

  def remove_punctuation(str)
    return '' if str.blank?
    str.to_s.gsub(/[^a-zA-Z0-9]+/, '')
  end

  def mask_phone(str)
    return '' if str.blank?
    numbers = str.to_s.gsub(/[^0-9]+/, '')

    case numbers.size
    when 13
      str.gsub(/\A(\d{2})(\d{2})(\d{3})(\d{3})(\d{3})\Z/, '+\\1 (\\2) \\3-\\4-\\5')
    when 12
      str.gsub(/\A(\d{2})(\d{2})(\d{4,5})(\d{4})\Z/, '+\\1 (\\2) \\3-\\4')
    when 11
      str.gsub(/[^\d]/, '').gsub(/\A(\d{2})(\d{3})(\d{3})(\d{3})\Z/, '(\\1) \\2-\\3-\\4')
    when 10
      str.gsub(/\A(\d{2})(\d{4})(\d{4})\Z/, '(\\1) \\2-\\3')
    when 9
      str.gsub(/\A(\d{3})(\d{3})(\d{3})\Z/, '\\1-\\2-\\3')
    when 8
      str.gsub(/\A(\d{4})(\d{4})\Z/, '\\1-\\2')
    else
      str
    end
  end

  def parse_phone(number, base_number)
    return '' if number.blank?
    number = number.to_s.gsub(/[^0-9]+/, '')

    case number.size
    when 8, 9
      number = number.insert(0, base_number[0, 4])

    when 10, 11
      number = number.insert(0, base_number[0, 2])

    when 12, 13
      return number

    else
      return ''
    end
  end

  def mask_cep(str)
    return '' if str.blank? || str.size < 8
    str.to_s.first(8).gsub(/\A(\d{5})(\d{3})\Z/, '\\1-\\2')
  end
end
