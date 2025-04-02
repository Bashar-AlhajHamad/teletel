require 'rails_helper'

RSpec.describe CustomRole, type: :model do
  # Test Associations
  describe "Associations" do
    it { should belong_to(:account) }
    it { should have_many(:account_users).dependent(:nullify) }
    it { should have_many(:custom_role_permissions).dependent(:destroy) }
    it { should have_many(:permissions).through(:custom_role_permissions) }
  end

  # Test Validations
  describe "Validations" do
    it { should validate_presence_of(:name) }

    it "is invalid if permissions contain invalid values" do
      custom_role = build(:custom_role)
    
      # Assign a permission that is not in the allowed list
      invalid_permission = create(:permission, action: "invalid_permission")
      custom_role.permissions << invalid_permission
    
      expect(custom_role.valid?).to be false
      expect(custom_role.errors[:permissions]).to include("includes invalid permissions: invalid_permission")
    end  
  end

  # Test Callbacks
  describe "Callbacks" do
    let!(:custom_role) { build(:custom_role, permissions: [Permission.new(action: "campaign_show")]) }

    it "calls ensure_valid_permissions before validation" do
      expect(custom_role).to receive(:ensure_valid_permissions)
      custom_role.valid?
    end
  end

  # Test Instance Methods
  describe "ensure_valid_permissions" do
    let!(:custom_role) { build(:custom_role, permissions: [Permission.new(action: "campaign_show")]) }

    it "ensures permissions are valid before saving" do
      valid_permission = create(:permission, action: "campaign_show") # Create a valid Permission object
      custom_role = build(:custom_role)
    
      custom_role.permissions << valid_permission # Assign a real Permission object
      custom_role.valid? # Trigger validation
    
      expect(custom_role.permissions.map(&:action)).to include("campaign_show")
    end
  end

  describe "permissions_checked?" do
    it "returns true if permissions have been checked" do
      custom_role = build(:custom_role)
      custom_role.instance_variable_set(:@permissions_checked, true)
      expect(custom_role.permissions_checked?).to be true
    end

    it "returns false if permissions have not been checked" do
      custom_role = build(:custom_role)
      expect(custom_role.permissions_checked?).to be false
    end
  end
end
