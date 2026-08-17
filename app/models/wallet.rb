class Wallet < ApplicationRecord
  belongs_to :user
  has_many :balances, class_name: "Balance"

  validates :id, Uuid: true, if: :id_must_be_check
  validates :user_id, Uuid: true
  validates :label, BaseStringLength: true, presence: true

  # Life cycle - Callback hooks
  after_initialize :after_initialize_callback, if: :new_record?

  def id_must_be_check
    !id.blank?
  end

  def after_initialize_callback
    uuid = UUID.new
    self.id = uuid.generate
    self.enable = true
    self.balances = 1.times.map do |index|
      Balance.new(user_id: self.user_id, wallet_id: self.id)
    end
  end
end
