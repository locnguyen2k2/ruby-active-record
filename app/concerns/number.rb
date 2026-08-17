module Number extend ActiveSupport::Concern
  include VnmMath
  included do
    self.cong
    puts "method_injected_by_foo from #{self.name}"
  end
end
