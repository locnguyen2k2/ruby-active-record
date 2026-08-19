module Fee
  extend ActiveSupport::Concern

  included do
    def fee_calculation
      puts "Your transaction fee is #{0.75}$"
    end

    def fees
      {
        usd: { vnd: 27000 }
      }
    end
  end
end
