FactoryGirl.define do

  factory :server, :class => SUPPORT::Server do
    ignore do
      ip       "33.33.33.10"
      port     "22"
      hostname "vagrant.vm"
      role     "primary"
    end

    initialize_with { new({:role => role}) }
  end

end
