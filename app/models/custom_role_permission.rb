# == Schema Information
#
# Table name: custom_role_permissions
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  custom_role_id :bigint           not null
#  permission_id  :bigint           not null
#
# Indexes
#
#  index_custom_role_permissions_on_custom_role_id  (custom_role_id)
#  index_custom_role_permissions_on_permission_id   (permission_id)
#
# Foreign Keys
#
#  fk_rails_...  (custom_role_id => custom_roles.id)
#  fk_rails_...  (permission_id => permissions.id)
#
class CustomRolePermission < ApplicationRecord
  belongs_to :custom_role, required: true
  belongs_to :permission, required: true

  validates :custom_role_id, uniqueness: { scope: :permission_id } # Prevents duplicates
end