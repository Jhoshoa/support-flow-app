class TeamMember < ApplicationRecord
  enum :role, { developer: 0, qa: 1, support: 2 }

  validates :name, presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true
end
