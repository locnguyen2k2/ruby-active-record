# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
User.destroy_all
RolePermission.destroy_all
Role.destroy_all
Permission.destroy_all
admin_id = UUID.new.generate
admin_role_id = ""
user_role_id = ""

roles = []
[
  { label: "Admin", slug: "admin" },
  { label: "User", slug: "user" }
].each do |role|
  created = Role.create(label: role[:label], slug: role[:slug], created_by: admin_id, enable: true)
  roles << created
  if role[:slug] == "admin"
    admin_role_id = created.id
  else
    user_role_id = created.id
  end
end

admin = User.create(id: admin_id, email: "stevennguyen@motorist.com", password: "123Steven", username: "stevennguyen", role_id: admin_role_id)
perms = [
  { resource: "user", action: "update", role_id: user_role_id },
  { resource: "user", action: "profile", role_id: admin_role_id },
  { resource: "user", action: "show", role_id: user_role_id },
  { resource: "user", action: "destroy", role_id: user_role_id },
  { resource: "user", action: "index", role_id: user_role_id },
  { resource: "role", action: "update", role_id: admin_role_id },
  { resource: "role", action: "delete", role_id: admin_role_id },
  { resource: "role", action: "profile", role_id: admin_role_id },
  { resource: "role", action: "show", role_id: admin_role_id },
  { resource: "role", action: "destroy", role_id: admin_role_id },
  { resource: "role", action: "index", role_id: admin_role_id },
  { resource: "permission", action: "update", role_id: admin_role_id },
  { resource: "permission", action: "delete", role_id: admin_role_id },
  { resource: "permission", action: "profile", role_id: admin_role_id },
  { resource: "permission", action: "show", role_id: admin_role_id },
  { resource: "permission", action: "destroy", role_id: admin_role_id },
  { resource: "permission", action: "index", role_id: admin_role_id }
]

perms.each do |resource|
  perm = Permission.create(created_by: admin.id, slug: "#{resource[:action]}_#{resource[:resource]}", label: "#{resource[:action].upcase} #{resource[:resource].upcase}")
  resource[:id] = perm.id
end

perms.each do |perm|
   RolePermission.create(role_id: perm[:role_id], permission_id: perm[:id])
end
