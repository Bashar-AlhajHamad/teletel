FactoryBot.define do
  factory :custom_role_permission do
    association :custom_role # Creates a real `CustomRole` record
    association :permission  # Creates a real `Permission` record
  end
end

