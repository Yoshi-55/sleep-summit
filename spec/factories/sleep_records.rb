FactoryBot.define do
  factory :sleep_record do
    wake_time { Time.current }
    bed_time { Time.current + 8.hours }
    association :user
  end
end
