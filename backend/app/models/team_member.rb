class TeamMember < ApplicationRecord
  enum :role, { developer: 0, qa: 1, support: 2 }

  has_many :created_requests, class_name: "SupportRequest", foreign_key: :creator_id, dependent: :restrict_with_error
  has_many :assigned_requests, class_name: "SupportRequest", foreign_key: :assignee_id, dependent: :nullify
  has_many :comments, dependent: :restrict_with_error

  validates :name, presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true
end
