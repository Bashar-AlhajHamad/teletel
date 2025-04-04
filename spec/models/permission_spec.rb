require 'rails_helper'

RSpec.describe Permission do
  # Test Associations
  describe "Associations" do
    it { should have_many(:custom_role_permissions).dependent(:destroy) }
    it { should have_many(:custom_roles).through(:custom_role_permissions) }
  end

  # Test Validations
  describe "Validations" do
    it { should validate_presence_of(:action) }
    it { should validate_presence_of(:controller) }
  end

  # Test Scopes
  describe ".by_controller" do
    let!(:permission1) { create(:permission, controller: "UsersController", action: "manage") }
    let!(:permission2) { create(:permission, controller: "ReportsController", action: "view") }

    it "returns permissions filtered by controller name" do
      expect(Permission.by_controller("UsersController")).to include(permission1)
      expect(Permission.by_controller("UsersController")).not_to include(permission2)
    end
  end

  # Test Instance Methods
  describe "display_name" do
    let(:permission) { build(:permission, controller: "users_controller", action: "manage") }

    it "returns a humanized display name" do
      expect(permission.display_name).to eq("Users controller - Manage")
    end
  end
end
