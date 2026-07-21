class SupportRequest < ApplicationRecord
  enum :status, { open: 0, in_progress: 1, resolved: 2, closed: 3 }
  enum :priority, { low: 0, medium: 1, high: 2, critical: 3 }

  belongs_to :creator, class_name: "TeamMember"
  belongs_to :assignee, class_name: "TeamMember", optional: true
  belongs_to :team, class_name: "TeamMember"

  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :description, presence: true
  validates :status, presence: true
  validates :priority, presence: true
  validates :creator, presence: true
  validates :team, presence: true

  validate :must_have_comments_to_resolve

  private

  def must_have_comments_to_resolve
    return unless status_changed?(to: :resolved)

    if comments.empty?
      errors.add(:status, "can't be resolved without at least one comment")
    end
  end
end
