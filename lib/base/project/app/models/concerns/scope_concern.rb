
module ScopeConcern
  extend ActiveSupport::Concern

  included do
    scope :created_since, ->(time) { where("#{table_name}.created_at >= ?", Date.parse(time).beginning_of_day) }
    scope :created_until, ->(time) { where("#{table_name}.created_at <= ?", Date.parse(time).end_of_day) }
    scope :created_between, ->(from, to) { created_since(from).created_until(to) }

    scope :updated_since, ->(time) { where("#{table_name}.updated_at >= ?", Date.parse(time).beginning_of_day) }
    scope :updated_until, ->(time) { where("#{table_name}.updated_at <= ?", Date.parse(time).end_of_day) }
    scope :updated_between, ->(from, to) { updated_since(from).updated_until(to) }
  end
end
