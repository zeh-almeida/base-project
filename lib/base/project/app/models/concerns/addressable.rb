module Addressable
  extend ActiveSupport::Concern

  included do
    before_validation :coordinates_precision
    normalize_attributes :zipcode, with: :remove_punctuation

    validates :default, inclusion: { in: [true, false] }
    validates :name, presence: true, length: { maximum: 100 }

    validates :country, presence: true, length: { maximum: 2, minimum: 2 }
    validates :state, presence: true, length: { maximum: 100 }
    validates :city, presence: true, length: { maximum: 100 }
    validates :street, presence: true, length: { maximum: 100 }
    validates :number, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :district, presence: true, length: { maximum: 100 }
    validates :zipcode, presence: true, length: { maximum: 8, minimmum: 8 }, format: { with: /\A\d*\z/i }

    validates :apartment, presence: false, numericality: { greater_than: 0 }, allow_blank: true
    validates :block, presence: false, length: { maximum: 100 }, allow_blank: true

    validates :latitude, presence: false, allow_blank: true
    validates :longitude, presence: false, allow_blank: true
    validate :unique_default_address

    scope :by_name,       ->(name)     { where("#{table_name}.name     ILIKE ?", "%#{name}%") }
    scope :by_country,    ->(country)  { where("#{table_name}.country  ILIKE ?", "%#{country}%") }
    scope :by_city,       ->(city)     { where("#{table_name}.city     ILIKE ?", "%#{city}%") }
    scope :by_street,     ->(street)   { where("#{table_name}.street   ILIKE ?", "%#{street}%") }
    scope :by_number,     ->(number)   { where("#{table_name}.number = ?", number.to_i.to_s) }
    scope :by_district,   ->(district) { where("#{table_name}.district ILIKE ?", "%#{district}%") }
    scope :by_zipcode,    ->(zipcode)  { where("#{table_name}.zipcode  ILIKE ?", "%#{StringSanitizer.remove_punctuation(zipcode)}%") }

    scope :regular_order, -> { order("#{table_name}.default DESC, #{table_name}.name") }
    scope :the_defaults, -> { where("#{table_name}.default = ?", true) }
  end

  def coordinates_precision
    self.latitude  = latitude.round(11)  if latitude.present?
    self.longitude = longitude.round(11) if longitude.present?
  end

  def multiple_default_error
    errors.add(:default, I18n.t('activerecord.errors.messages.default_address_already_exists'))
  end

  def formatted_simple
    text = "#{street} #{number}"

    text = "#{text}, ap.#{apartment}" if apartment
    text = "#{text}, bl.#{block}" if block

    "#{text}, #{district}, #{city}"
  end

  def formatted_zipcode
    StringSanitizer.mask_cep(zipcode)
  end

  def formatted_country
    country_model = ISO3166::Country[country]
    country_model.translations[country] || country_model.name
  end

  def formatted_complete
    "#{formatted_simple}, #{formatted_zipcode} #{formatted_country}"
  end

  def coordinate_pair
    [latitude, longitude]
  end

  def coordinates_dms
    latitude_dms = coordinate_to_dms(latitude, %w[N S])
    longitude_dms = coordinate_to_dms(longitude, %w[E W])

    [latitude_dms, longitude_dms]
  end

  private

  def coordinate_to_dms(coordinate_value, directions)
    value = coordinate_value.abs

    degrees = value.floor
    direction = (latitude > 0 ? directions.first : directions.last)

    minutes = (((value - degrees) * 60)).round(3).floor
    seconds = (((value - degrees) * 3600) - (minutes * 60)).round(3).floor

    "#{degrees}° #{minutes}′ #{seconds}\"#{direction}"
  end
end
