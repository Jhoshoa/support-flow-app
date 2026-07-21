class AddDueDateToSupportRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :support_requests, :due_date, :date
  end
end
