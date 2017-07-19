class FormUser < User
  attr_accessor :current_password

  validates :email, presence: { if: :email_required? }
  validates :email, uniqueness: { allow_blank: true, if: :email_changed? }
  validates     :email, format: { with: Devise.email_regexp, allow_blank: true, if: :email_changed? }

  validates     :password, presence: { if: :password_required? }
  validates :password, confirmation: { if: :password_required? }
  validates :password, length: { within: Devise.password_length, allow_blank: true }

  def password_required?
    return false if email.blank?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  def email_required?
    true
  end
end
