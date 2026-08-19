class User < ApplicationRecord
  include Invoice

  has_many :wallets, class_name: "Wallet", before_add: :before_add_callback, dependent: :destroy
  belongs_to :role, class_name: "Role"

  has_secure_password
  attr_accessor :old_password, :remember_token

  # Create reused queries => ActiveRecord_Relation
  scope :by_id, ->(id) { find(id) if id.present? }
  scope :is_actived, -> {  where(status: "actived") }
  scope :is_unactived, Proc.new { where(status: "unactive") }
  scope :raw_find_by_id, Proc.new {  "SELECT * FROM users WHERE enable = 1 " }
  # ActiveRecord::Base.connection.exec_query -> ActiveRecord::Result(object)
  # scope :available_role_by_slug, ->(slug) { where(slug: slug, enable: true)  }

  validates :password, presence: true, on: :create

  # Methods validator: for specific model
  # - validate with specific methods, blocks
  validate :valid_username, on: :create

  # Class validator: for reusable between class
  # - a shortcut to all default validators and any custom validator classes ending in 'Validator'
  validates :email, email: true, if: :new_record?
  # - without default error's message, need to add error'message in validator class
  # validates_with EmailValidator
  validates_with EmailValidator
  # Context validator: validate with specific condition/context
  validate :does_not_have_any_wallet, on: :available_to_destroy

  # Validation callback hooks
  before_validation :before_validation_callback
  after_validation :after_validation_callback

  # Run after when the instance was initialized
  after_initialize :after_initialize_callback, if: :new_record?
  # Run after when the record was loadded from DB
  after_find :after_find_callback

  around_create :around_create_callback
  before_create :before_create_callback
  after_create :after_create_callback
  after_create_commit :after_create_commit_callback

  # These callbacks will run each time when an object was saved(create/update)
  # before_save :before_save_callback
  # after_save :after_save_callback
  # around_save :around_save_callback

  # around_update :around_update_callback
  # before_update :after_update_callback
  # after_update :before_update_callback
  # after_update_commit :after_update_commit_callback

  after_rollback :after_rollback_callback
  after_commit :after_commit_callback

  # def total_

  def greeting
    puts "Good morning"
    super
  end

  def self.do_something_with_second_yied(&block)
    puts "The second yield is starting ... #{oke}"
    block.call
  end

  def self.do_something_with_yied
    return "Block not given" unless block_given?
    puts "Yield is starting ..."
    yield "Steven"
    self.do_something_with_second_yied do yield "Cjool" end
    puts "Yield is completed"
  end

  def self.do_something_with_block(&block)
    puts "Block is starting ..."
    block.call "Steven" => "1", "2" => "3"
    # block.call "Cjool"
    puts "Block is completed"
  end

  def self.with_lambda
    lamb = ->(**name) {
      name.map do |label, val|
        puts "My name is #{label} - age #{val}"; nil
      end
     }
    self.do_something_with_block lamb.call
  end

  def self.with_proc
    proc = Proc.new do |name|
      puts "My name is #{name}"
       # return
     end
    self.do_something_with_yied &proc
  end

  def self.status(id)
    { "#{id} - " => User.by_id(id)[:status] }
  end

  def self.active(id)
    User.by_id(id).update(status: "actived")
  end

  def self.unactive(id)
    User.by_id(id).update(status: "unactived")
  end

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, const: cost)
  end

  def owner_of?(item)
    self.id == item.created_by
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end
  def authenticated?(remember_token)
    return false if self.remember_digest.nil?
    BCrypt::Password.new(self.remember_digest) == remember_token
  end


  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_token, User.digest(remember_token))
  end
  def forgot
    update_attribute(:remember_digest, nil)
  end

  def limit_reached?
    self.wallets.length == 4
  end

  def before_validation_callback
    puts "[user_before_validation] before validation, [openning-transaction - false]"
  end

  def after_validation_callback
    puts "[user_after_validation] [openning-transaction - false]"
  end

  def after_initialize_callback
      puts "[user_after_intialize]"
      uuid = UUID.new
      self.id = uuid.generate
      self.status = "unactive" if self.status.blank?
      self.role = Role.available_role_by_slug
      self.wallets = 2.times.map do |index|
        Wallet.new(label: "Wallet #{index}", user_id: self.id)
      end
  end
  def after_find_callback
    self.enable = "false" if self.enable.blank?
  end

  def before_create_callback
    puts "[user_before_create]", { "openning-transaction" => true, "written" => false, "committed" => false }
    self.email = self.email.downcase
  end
  def after_create_callback
    puts "[user_after_create]", { "openning-transaction" => true, "written" => true, "committed" => false }
    # Do the some kind of triggers such as: Mail sending, Catching, ...v.v
  end
  def around_create_callback
    self.before_create_callback
    yield
    self.after_create_callback
  end
  def after_create_commit_callback
    puts "[user_after_create_commit]", { "completed-transaction" => true, "committed" => true }
  end

  def before_update_callback
    puts "[user_before_update]", { "openning-transaction" => true, "written" => false, "committed" => false }
    self.email = self.email.downcase
  end
  def after_update_callback
    puts "[user_after_update]", { "openning-transaction" => true, "written" => true, "committed" => false }
  end
  def around_update_callback
    self.before_update_callback
    yield
    # throw :abort
    self.after_update_callback
  end
  def after_update_commit_callback
    puts "[user_after_update_commit]", { "completed-transaction" => true, "committed" => true }
  end

  def before_save_callback
      puts "[user_before_save]", { "openning-transaction" => true, "committed" => false }
  end
  def after_save_callback
      puts "[user_after_save]", { "openning-transaction" => true, "committed" => false }
  end
  def around_save_callback
    self.before_save_callback
    yield
    self.after_save_callback
  end

  def after_rollback_callback
    puts "[user_after_rollback]", { "completed-transaction" => true, "rollbacked" => true }
  end
  def after_commit_callback
   puts "[user_after_commit]", { "completed-transaction" => true, "committed" => true }
  end

  # Association callback hooks
  def before_add_callback(wallet)
    puts "[association_before_add] [#{wallets.length}/#{4}] [limit_reached: #{limit_reached?}]"
    throw :abort if limit_reached?
  end

  private
  def must_be_check
    # Apply password check when: Create & Change password
    (username.present? and new_record?)
  end

  def valid_username
    errors.add :username, "must be valid!" unless self.username&.match?(RegexData::USERNAME_REGEX)
  end
  def action_by_owner
    errors.add(:wallets, "is not empty (#{wallets.length})") if wallets.exists?
  end
  def does_not_have_any_wallet
    errors.add(:wallets, "is not empty (#{wallets.length})") if wallets.exists?
  end
end
