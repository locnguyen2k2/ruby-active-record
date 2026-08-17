Here is a structured, complete documentation section on **ActiveRecord Validations, Callbacks, and Custom Validation Patterns** for your self-learning guide.

---

# Module: ActiveRecord Data Integrity

## Section 5.1 — Validations, Callback Lifecycles, and Custom Rules

### 1. Overview

ActiveRecord provides two distinct tools for managing object lifecycles:

* **Validations:** Pure rules designed to evaluate data integrity before persistence.
* **Callbacks:** Event hooks that trigger side effects or transform data at specific points in an object’s lifecycle.

Understanding where validations fit inside the callback lifecycle—and why they should remain separate—is fundamental to writing clean Rails models.

---

### 2. Complete ActiveRecord Callback Order

Every ActiveRecord interaction follows a strict execution path. Throwing `throw :abort` inside any `before_*` callback cancels the entire database transaction.

```text
  Instantiation:   after_initialize -> after_find
  ----------------------------------------------------------------------
  Save Flow:       before_validation
                   -> validate
                   -> after_validation
                   -> before_save
                   -> before_create / before_update
                   -> [ DATABASE TRANSACTION (INSERT/UPDATE) ]
                   -> after_create / after_update
                   -> after_save
                   -> after_commit / after_rollback
  ----------------------------------------------------------------------
  Destroy Flow:    before_destroy
                   -> [ DATABASE TRANSACTION (DELETE) ]
                   -> after_destroy
                   -> after_commit / after_rollback

```

#### Available Callbacks Summary

| Lifecycle Event | Callbacks Available | Common Use Cases |
| --- | --- | --- |
| **Initialize / Find** | `after_initialize`, `after_find` | Setting default values on new objects |
| **Validation** | `before_validation`, `after_validation` | Normalizing strings (e.g., `strip`, `downcase`) before checks run |
| **Save** *(Create & Update)* | `before_save`, `around_save`, `after_save`, `after_commit` | Calculating aggregate totals, clearing caches |
| **Create** *(Insert only)* | `before_create`, `around_create`, `after_create` | Generating API tokens, hashing passwords |
| **Update** *(Update only)* | `before_update`, `around_update`, `after_update` | Recording change logs or audit trails |
| **Destroy** *(Delete)* | `before_destroy`, `around_destroy`, `after_destroy` | Checking dependency locks, soft-deleting attached files |
| **Touch** *(Timestamp update)* | `after_touch` | Flushing low-level key-value caches |

---

### 3. Why Use Validations Instead of Callbacks to Validate Data?

While a `before_save` callback *can* stop a record from saving using `throw :abort`, using callbacks to validate data is an **anti-pattern**.

```ruby
# ❌ ANTI-PATTERN: Validating inside callbacks
class User < ApplicationRecord
  before_save :check_email_presence

  private

  def check_email_presence
    if email.blank?
      errors.add(:email, "can't be blank")
      throw :abort
    end
  end
end

# ✅ IDIOMATIC RAILS: Using Validations
class User < ApplicationRecord
  validates :email, presence: true
end

```

#### Key Differences & Architectural Advantages

1. **Separation of Concerns:** Validations inspect **state** (Is this valid?). Callbacks trigger **side-effects** (Send email, strip whitespace, hash password).
2. **Form & UI Integration:** Standard validations populate `user.errors` automatically. Form helpers (`form_with`) seamlessly render validation error messages. Callback errors require manual string handling and explicit `throw :abort` logic.
3. **Inspection without Persistence (`valid?` / `invalid?`):** Running `user.valid?` checks validation rules *without entering a database transaction*. Callbacks like `before_save` or `before_create` require calling `.save`, forcing a transaction opening.
4. **Bypassing Rules (`validate: false`):** Admins or background jobs sometimes need to bypass validation rules (e.g., `user.save(validate: false)`). Validations respect this flag; `before_save` callbacks **ignore `validate: false**` and execute anyway.

---

### 4. Custom Validation Strategies: Methods vs. Custom Validators vs. Contexts

Rails provides three primary ways to implement custom validation logic depending on reuse and complexity.

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                       Custom Validation Options                         │
├───────────────────────────┬─────────────────────────┬───────────────────┤
│    Custom Methods         │    Custom Validators    │  Validation       │
│    (validate :method)     │    (ActiveModel)        │  Contexts         │
├───────────────────────────┼─────────────────────────┼───────────────────┤
│ • Model-specific rules    │ • Reusable across models│ • Conditional     │
│ • Quick inline checks     │ • Encapsulated logic    │   action rules    │
└───────────────────────────┴─────────────────────────┴───────────────────┘

```

#### Strategy 1: Custom Validation Methods (`validate :method_name`)

Use when validation logic is **unique to a single model** and doesn't need to be shared across the application.

```ruby
class Event < ApplicationRecord
  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end

```

---

#### Strategy 2: Custom ActiveModel Validators

Use when you want **reusable validation rules** across multiple models (e.g., verifying tax IDs, phone formats, or image upload dimensions).

##### Option A: Custom Attribute Validator (`ActiveModel::EachValidator`)

```ruby
# app/validators/email_format_validator.rb
class EmailFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ URI::MailTo::EMAIL_REGEXP
      record.errors.add(attribute, (options[:message] || "is not a valid email address"))
    end
  end
end

# Usage in ANY model:
class User < ApplicationRecord
  validates :email, presence: true, email_format: true
end

class AuthorProfile < ApplicationRecord
  validates :contact_email, email_format: { message: "must be formatted correctly" }
end

```

##### Option B: Custom Record Validator (`ActiveModel::Validator`)

Validates entire records across multiple attributes at once.

```ruby
# app/validators/publishing_readiness_validator.rb
class PublishingReadinessValidator < ActiveModel::Validator
  def validate(record)
    if record.published? && record.content.blank?
      record.errors.add(:base, "Published records must contain content")
    end
  end
end

# Usage:
class Book < ApplicationRecord
  validates_with PublishingReadinessValidator
end

```

---

#### Strategy 3: Validation Contexts

Use when validation rules should **only apply under specific actions or workflows** (e.g., user signup vs. admin account update, draft vs. published state).

```ruby
class User < ApplicationRecord
  # Always runs
  validates :email, presence: true

  # Only runs when specifically saved under the :onboarding context
  validates :terms_of_service, acceptance: true, on: :onboarding
  
  # Only runs on update
  validates :bio, presence: true, on: :update
end

# Usage:
user = User.new(email: "alex@example.com")
user.save # => true (terms_of_service was ignored)

user.save(context: :onboarding) # => false (fails terms_of_service check)

```

---

### 5. Summary Comparison Matrix

| Approach | Where Code Lives | Scope / Reuse | Primary Purpose |
| --- | --- | --- | --- |
| **`validates` Macros** | Model file | Single attribute | Built-in rules (`presence`, `length`, `uniqueness`) |
| **Custom Methods** | Model file (`private`) | Single model | One-off, complex multi-field calculations |
| **EachValidator** | `app/validators/` | App-wide across models | Reusable single-attribute checks (email, phone, SSN) |
| **Validator** | `app/validators/` | App-wide across models | Reusable whole-record checks |
| **Validation Contexts** | Model file (`on: :context`) | Action-specific | Enforcing rules for specific multi-step workflows |