    module Invoice
      extend ActiveSupport::Concern
      include Fee
      include Transaction
      include Sender

      included do
        def gen_invoice
          fee_calculation
          pdf
          invoice
        end
      end
    end
