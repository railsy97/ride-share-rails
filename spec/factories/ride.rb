FactoryBot.define do
    factory :ride do
      pick_up_time { Date.today + 5.days }
      reason {"Interview"}
      status { "pending"}

    end
end
