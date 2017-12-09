
module Base::Project::App::Models::Concerns::BaseUserConcern
  extend ActiveSupport::Concern

  included do
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable

    before_save :check_password_changed

    normalize_attributes :cpf, with: :remove_punctuation, if: ->(_attr) { cpf.present? }
    validates_cpf_format_of :cpf, if: ->(_attr) { cpf.present? }

    validates :cpf,   allow_blank: true, uniqueness: true
    validates :name,  presence: true, uniqueness: false
    validates :email, presence: true, uniqueness: true, format: { with: Devise.email_regexp }
    validates :updated_password, inclusion: { in: [true, false] }

    scope :by_cpf,   ->(cpf)   { where("#{table_name}.cpf            ILIKE ?", "%#{Base::Project::Lib::StringSanitizer.remove_punctuation(cpf)}%") }
    scope :by_email, ->(email) { where("#{table_name}.email          ILIKE ?", "%#{email}%") }
    scope :by_name,  ->(name)  { where("unaccent(#{table_name}.name) ILIKE ?", "%#{name}%") }

    def password_required?
      new_record? ? false : super
    end

    private

    def check_password_changed
      if changed.include?('encrypted_password')
        self.updated_password = attributes['encrypted_password'] != encrypted_password_was
      end

      nil
    end
  end
end
