puts "Seeding database..."

# --- Team Members ---
puts "  Creating team members..."
members = [
  { name: "Ana Garcia", email: "ana@supportflow.dev", role: :support, active: true },
  { name: "Carlos Lopez", email: "carlos@supportflow.dev", role: :developer, active: true },
  { name: "Maria Rodriguez", email: "maria@supportflow.dev", role: :qa, active: true },
  { name: "Pedro Martinez", email: "pedro@supportflow.dev", role: :developer, active: true },
  { name: "Laura Sanchez", email: "laura@supportflow.dev", role: :support, active: true },
  { name: "Diego Torres", email: "diego@supportflow.dev", role: :developer, active: false },
  { name: "Sofia Hernandez", email: "sofia@supportflow.dev", role: :qa, active: true }
]

team_members = members.map do |attrs|
  TeamMember.find_or_create_by!(email: attrs[:email]) do |m|
    m.name = attrs[:name]
    m.role = attrs[:role]
    m.active = attrs[:active]
  end
end

support_team = team_members.select { |m| m.role == "support" }
dev_team = team_members.select { |m| m.role == "developer" }
qa_team = team_members.select { |m| m.role == "qa" }

puts "    Created #{team_members.size} team members"

# --- Support Requests (create as open first) ---
puts "  Creating support requests..."

requests_data = [
  { title: "Login page not loading", description: "Users report the login page shows a blank screen after the latest deploy.", status: :open, priority: :critical, creator: support_team.first, team: support_team.first },
  { title: "Dashboard slow on large datasets", description: "When a team has more than 1000 requests, the dashboard takes over 10 seconds to load.", status: :open, priority: :high, creator: dev_team.first, team: dev_team.first },
  { title: "Email notifications not sending", description: "Support request creators are not receiving email notifications when their requests are updated.", status: :open, priority: :medium, creator: support_team.last, team: support_team.last },
  { title: "Filter by priority not working", description: "Clicking on the priority filter does not update the request list.", status: :open, priority: :low, creator: qa_team.first, team: qa_team.first },
  { title: "Cannot assign request to inactive member", description: "The system allows assigning requests to inactive team members, causing silent failures.", status: :in_progress, priority: :high, creator: support_team.first, assignee: dev_team.first, team: dev_team.first },
  { title: "Comment validation error", description: "Users can submit comments with empty body. Should require minimum 10 characters.", status: :in_progress, priority: :medium, creator: qa_team.first, assignee: dev_team.last, team: dev_team.first },
  { title: "Mobile responsive layout broken", description: "The request detail page does not render correctly on mobile devices under 768px width.", status: :in_progress, priority: :medium, creator: support_team.last, assignee: dev_team[1], team: dev_team.first },
  { title: "Search feature returns duplicates", description: "Searching by title sometimes returns the same request multiple times.", status: :in_progress, priority: :high, creator: dev_team.first, assignee: dev_team.first, team: dev_team.first },
  # Resolved/Closed will be created as open first, then updated after adding comments
  { title: "Duplicate account creation", description: "Users were able to create multiple accounts with the same email address.", status: :open, priority: :critical, creator: support_team.first, assignee: dev_team.first, team: dev_team.first },
  { title: "Wrong status shown on dashboard", description: "The dashboard was showing open requests count instead of in_progress.", status: :open, priority: :medium, creator: qa_team.first, assignee: dev_team[1], team: dev_team.first },
  { title: "API returning 500 on empty team", description: "GET /api/v1/team_members returned internal server error when no members existed.", status: :open, priority: :high, creator: dev_team.last, assignee: dev_team.first, team: dev_team.first },
  { title: "Pagination not working", description: "The next page button on the request list was not navigating correctly.", status: :open, priority: :low, creator: qa_team.first, assignee: dev_team.first, team: dev_team.first },
  { title: "Missing favicon", description: "The browser tab showed the default Rails icon instead of the SupportFlow logo.", status: :open, priority: :low, creator: support_team.last, assignee: dev_team[1], team: dev_team.first },
  { title: "Dark mode color contrast issues", description: "Some text elements are hard to read in dark mode due to low contrast ratios.", status: :open, priority: :medium, creator: qa_team.first, team: qa_team.first },
  { title: "Export to CSV feature request", description: "Managers need to export filtered support requests to CSV for weekly reports.", status: :open, priority: :low, creator: support_team.first, team: support_team.first },
  { title: "Overdue requests not highlighted", description: "Requests past their due date should have a visual indicator.", status: :open, priority: :high, creator: dev_team.first, team: dev_team.first }
]

support_requests = requests_data.map do |data|
  SupportRequest.find_or_create_by!(title: data[:title]) do |sr|
    sr.description = data[:description]
    sr.status = data[:status]
    sr.priority = data[:priority]
    sr.creator = data[:creator]
    sr.assignee = data[:assignee]
    sr.team = data[:team]
  end
end

puts "    Created #{support_requests.size} support requests"

# --- Comments ---
puts "  Creating comments..."

resolved_requests = [support_requests[8], support_requests[9], support_requests[10]]
closed_requests = [support_requests[11], support_requests[12]]

comments_data = [
  # Comments on request that will become resolved "Duplicate account creation"
  { body: "Confirmed the bug. The email uniqueness validation was missing in the model.", support_request: resolved_requests[0], team_member: dev_team.first },
  { body: "Fix deployed to staging. Added unique index on email column.", support_request: resolved_requests[0], team_member: dev_team.first },
  { body: "Tested on staging, the fix works correctly. Marking as resolved.", support_request: resolved_requests[0], team_member: qa_team.first },

  # Comments on request that will become resolved "Wrong status shown on dashboard"
  { body: "Found the issue. The dashboard query was using the wrong enum value.", support_request: resolved_requests[1], team_member: dev_team[1] },
  { body: "Fix merged. Dashboard now shows correct counts.", support_request: resolved_requests[1], team_member: qa_team.first },

  # Comments on request that will become resolved "API returning 500"
  { body: "The controller was calling .first on an empty collection without checking.", support_request: resolved_requests[2], team_member: dev_team.first },
  { body: "Added proper empty state handling. Returns empty array instead of 500.", support_request: resolved_requests[2], team_member: dev_team.first },

  # Comments on request that will become closed "Pagination not working"
  { body: "Found the bug in the pagination component. The page parameter was not being passed.", support_request: closed_requests[0], team_member: dev_team.first },
  { body: "Fix is ready. It was a simple missing param.", support_request: closed_requests[0], team_member: dev_team.first },

  # Comments on request that will become closed "Missing favicon"
  { body: "Added the favicon to the public directory and updated the layout.", support_request: closed_requests[1], team_member: dev_team[1] },

  # Comments on in-progress requests
  { body: "Looking into this now. Need to add a validation in the controller.", support_request: support_requests[4], team_member: dev_team.first },
  { body: "The Comment model needs validates :body, presence: true, length: { minimum: 10 }", support_request: support_requests[5], team_member: dev_team.last },

  # Comments on open requests
  { body: "This is critical. Investigating if it's related to the latest webpack build.", support_request: support_requests[0], team_member: dev_team.first },
  { body: "Confirmed it's a build issue. The CSS file is not being included in production.", support_request: support_requests[0], team_member: dev_team.first }
]

comments_data.each do |data|
  Comment.find_or_create_by!(
    support_request: data[:support_request],
    team_member: data[:team_member],
    body: data[:body]
  )
end

puts "    Created #{Comment.count} comments"

# --- Update resolved/closed requests (must happen AFTER comments) ---
puts "  Updating resolved and closed requests..."

resolved_requests.each do |sr|
  sr.update!(status: :resolved, resolved_at: rand(1..3).days.ago)
end

closed_requests.each do |sr|
  sr.update!(status: :closed, resolved_at: rand(4..5).days.ago)
end

puts "    Updated #{resolved_requests.size} resolved + #{closed_requests.size} closed"

puts ""
puts "Seeding complete!"
puts ""
puts "Summary:"
puts "  Team Members: #{TeamMember.count}"
puts "  Support Requests: #{SupportRequest.count} (#{SupportRequest.open.count} open, #{SupportRequest.in_progress.count} in_progress, #{SupportRequest.resolved.count} resolved, #{SupportRequest.closed.count} closed)"
puts "  Comments: #{Comment.count}"
