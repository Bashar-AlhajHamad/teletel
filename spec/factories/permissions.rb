FactoryBot.define do
  factory :permission do
    action { Faker::Lorem.word.downcase } # ✅ Ensures lowercase words
    controller { "#{Faker::Lorem.word.capitalize}Controller" } # ✅ Ensures correct controller format
  end
end
