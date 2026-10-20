class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :oauth_identities, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :name, presence: true, length: { maximum: 100 }
  validates :email_address, presence: true, uniqueness: { case_sensitive: false}, format: { with: URI::MailTo::EMAIL_REGEXP }
end
