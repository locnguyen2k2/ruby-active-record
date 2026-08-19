module Asset extend ActiveSupport::Concern
  include Fee

  def balance_calculate_handler
    fee = fees[:usd][:vnd]
    res = yield fee
    puts "Your current balance: #{res[:before_rate]}$ #{res[:after_rate]}VND"
  end

  included do
    def total_balance
      balance_calculation = ->(fee) {
        raw = balances && balances.length ? balances.reduce(0) { |m, n| m + (n[:value]) } : 0
        rate = raw * fee
        {
          before_rate: raw,
          after_rate: rate
        }
      }
      balance_calculate_handler &balance_calculation
    end
  end
end
