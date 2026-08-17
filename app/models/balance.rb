class Balance < ApplicationRecord
  belongs_to :user, required: false
  belongs_to :wallet, required: true

  @@maximum = 50
  private attr_accessor :amount

  validates :id, Uuid: true, if: :id_must_be_check
  validates :wallet_id, :user_id, Uuid: true
  validate :amount_must_be_greater_than_value, on: :desc
  validate :max_out, on: :inc

  after_validation :after_desc_valid, on: :desc
  after_validation :after_inc_valid, on: :inc

  after_initialize :after_initialize_callback
  before_save :before_save_callback, unless: :new_record?

  def desc(amount)
    self.amount = amount
    return false unless valid?(:desc)
    self.value -= self.amount
    self.update_balance
  end
  def inc(amount)
    self.amount = amount
    return false unless valid?(:inc)
    self.value += self.amount
    self.update_balance
  end


  def after_initialize_callback
    self.value = 0 if self.value.nil?
    puts "[balance_after_initialize] #{self.value}"
  end

  def before_save_callback
    puts "[balance_updating_balance]"
    throw :abort if self.value < 0
  end

  def after_update_callback
    puts "[balance_updated_balance]"
  end

  private
  def update_balance
    Balance.where(id: self.id).update(value: self.value)
  end
  def id_must_be_check
    !id.blank?
  end

  def amount_must_be_greater_than_value
    errors.add :amount, "(#{self.amount}) is greater than current available value #{self.value}" if self.amount > self.value
  end
  def after_desc_valid
    puts "[balance_after_validate] New balance value = #{self.value}"
  end

  def max_out
    errors.add :amount, "(#{self.amount}) must be less than or equal #{@@maximum}" if self.amount > @@maximum
  end
  def after_inc_valid
    puts "[balance_after_validate] New balance value = #{self.value}"
  end
end
