module VnmMath extend ActiveSupport::Concern
included do
      def self.cong(a, b)
        a+b
      end
      def self.tru(a, b)
        a-b
      end
    end
end
