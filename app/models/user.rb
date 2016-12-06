class User < ApplicationRecord
  has_one :manager, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :username,
            presence: true,
            uniqueness: {
              case_sensitive: false
            }
  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, multiline: true

  after_create :create_manager

  def create_manager
    Manager.create user: self
  end

  def admin?
    admin
  end

  def registered?
    self.persisted?
  end

  def owner?
    username == admin && email == "arj.rdh@gmail.com"
  end

end
