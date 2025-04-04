# == Schema Information
#
# Table name: custom_roles
#
#  id          :bigint           not null, primary key
#  description :string
#  name        :string
#  permissions :text             default([]), is an Array
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  account_id  :bigint           not null
#
# Indexes
#
#  index_custom_roles_on_account_id  (account_id)
#
#

# Available permissions for custom roles:
# - 'conversation_manage': Can manage all conversations.
# - 'conversation_unassigned_manage': Can manage unassigned conversations and assign to self.
# - 'conversation_participating_manage': Can manage conversations they are participating in (assigned to or a participant).
# - 'contact_manage': Can manage contacts.
# - 'report_manage': Can manage reports.
# - 'knowledge_base_manage': Can manage knowledge base portals.

class CustomRole < ApplicationRecord
  belongs_to :account
  has_many :account_users, dependent: :nullify
  has_many :custom_role_permissions, dependent: :destroy
  has_many :permissions, through: :custom_role_permissions

  PERMISSIONS = %w[
    conversation_manage
    conversation_unassigned_manage
    conversation_participating_manage
    campaign_show
    campaign_create
    campaign_update
    campaign_destroy
    reports_show
    reports_download
    contact_show
    contact_create
    contact_update
    contact_destroy
    contact_import
    contact_export
    contact_merge
    contact_block
    contact_unblock
    knowledge_base_manage
  ].freeze

  validates :name, presence: true

  # Validate that each permission passed is in the list of valid permissions
  validate :valid_permissions

  before_validation :ensure_valid_permissions, unless: -> { permissions_checked? }

  def ensure_valid_permissions
    # @permissions_checked = true
    # # Convert string permissions to actual Permission objects, if valid
    # self.permissions = permissions.map do |p|
    #   permission = Permission.find_by(action: p)
    #   permission if PERMISSIONS.include?(p)
    # end.compact
    return if permissions.blank?

    @permissions_checked = true

    valid_permissions = permissions.map do |p|
      p.is_a?(String) ? Permission.find_by(action: p) : p
    end.compact

    self.permissions = valid_permissions # ✅ Now properly assigns to association
  end

  def permissions_checked?
    @permissions_checked == true
  end

  private

  # Custom validation to ensure that all permissions are included in the valid list
  def valid_permissions
    # invalid_permissions = permissions.reject { |p| PERMISSIONS.include?(p) }
    # if invalid_permissions.any?
    #   errors.add(:permissions, "includes invalid permissions: #{invalid_permissions.join(', ')}")
    # end
    return if permissions.blank?

    assigned_actions = permissions.map(&:action) # ✅ Extract actions from Permission objects
    invalid_permissions = assigned_actions - PERMISSIONS
  
    if invalid_permissions.any?
      errors.add(:permissions, "includes invalid permissions: #{invalid_permissions.join(', ')}")
    end
  end
end