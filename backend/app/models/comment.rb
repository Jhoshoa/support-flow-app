class Comment < ApplicationRecord
  belongs_to :support_request
  belongs_to :team_member

  validates :body, presence: true, length: { minimum: 10 }
end
