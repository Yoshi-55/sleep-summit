FactoryBot.define do
  factory :sleep_record do
    wake_time { 1.day.ago.change(hour: 6, min: 0) }
    bed_time { 1.day.ago.change(hour: 23, min: 0) }
    association :user

    trait :unbedded do
      bed_time { nil }
    end
  end
end
