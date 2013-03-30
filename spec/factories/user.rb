FactoryGirl.define do

  factory :user, :class => SUPPORT::User do
    ignore do
      username "sysadmin"
      password "vagrant"
      role     "install"
      enabled  true
    end

    trait :root do
      role "root"
      enabled false
    end

    trait :install do
      role "sysadmin"
    end

    trait :personal do
      role "steven"
    end

    trait :app do
      role "vagrant"
    end

    initialize_with { new({:username => username, :password => password, :role => role, :enabled => enabled}) }
  end

end
