require 'rails_helper'

RSpec.describe CustomRolePermission do
  # Test Associations
  describe "Associations" do
    it { is_expected.to belong_to(:custom_role).required }
    it { is_expected.to belong_to(:permission).required }
  end

  # Test Validations (Remove `validate_presence_of`)
  describe "Validations" do
    it "is invalid without a custom_role" do
      expect(build(:custom_role_permission, custom_role: nil)).to be_invalid
    end

    it "is invalid without a permission" do
      expect(build(:custom_role_permission, permission: nil)).to be_invalid
    end
  end
end
