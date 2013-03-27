FactoryGirl.define do

  factory :server_user, :class => SUPPORT::ServerUser do
    ignore do
      role     "primary"
    end

    trait :primary do
      role "primary"
    end

    initialize_with { new({:role => role}) }
  end

end
