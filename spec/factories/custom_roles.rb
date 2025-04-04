FactoryBot.define do
  factory :custom_role do
    account
    name { Faker::Name.name }
    description { Faker::Lorem.sentence }

    # ✅ Ensure the role has associated permissions
    after(:create) do |custom_role|
      create_list(:custom_role_permission, 2, custom_role: custom_role) # ✅ Creates 2 random permissions
    end
  end
end
