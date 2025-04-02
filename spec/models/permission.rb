# == Schema Information
#
# Table name: permissions
#
#  id         :bigint           not null, primary key
#  action     :string
#  controller :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Permission < ApplicationRecord
  # Associations
  has_many :custom_role_permissions, dependent: :destroy
  has_many :custom_roles, through: :custom_role_permissions

  # Validations
  validates :action, presence: true
  validates :controller, presence: true

  # Scopes
  scope :by_controller, ->(controller) { where(controller: controller) }

  # Instance Methods
  def display_name
    "#{controller.humanize} - #{action.humanize}"
  end
end