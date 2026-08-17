# Active Record — Ruby on Rails

A practical reference for Active Record concepts, query interface, persistence, lifecycle, associations, validation, callbacks, transactions, serialization, and performance.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Model and Active Record Objects](#2-model-and-active-record-objects)
3. [ActiveRecord::Relation and Lazy Loading](#3-activerecordrelation-and-lazy-loading)
4. [CRUD and Persistence](#4-crud-and-persistence)
5. [Query Interface](#5-query-interface)
6. [Scopes](#6-scopes)
7. [Associations](#7-associations)
8. [Association Loading](#8-association-loading)
9. [Validation](#9-validation)
10. [Callbacks](#10-callbacks)
11. [Validation vs Callback](#11-validation-vs-callback)
12. [Transactions](#12-transactions)
13. [Dirty Tracking](#13-dirty-tracking)
14. [Attributes and Data Representation](#14-attributes-and-data-representation)
15. [Serialization and Serializers](#15-serialization-and-serializers)
16. [Select, Pluck, Pick and Aggregations](#16-select-pluck-pick-and-aggregations)
17. [Enum](#17-enum)
18. [Database Constraints](#18-database-constraints)
19. [Locking and Concurrency](#19-locking-and-concurrency)
20. [Batch Processing](#20-batch-processing)
21. [Performance and N+1](#21-performance-and-n1)
22. [Raw SQL](#22-raw-sql)
23. [Active Record Mental Model](#23-active-record-mental-model)
24. [Learning Checklist](#24-learning-checklist)

---

# 1. Overview

Active Record is Rails' ORM (Object-Relational Mapping).

It maps:

```text
Ruby Model Object
       ↕
   Active Record
       ↕
   Database Table
```

Example:

```ruby
class User < ApplicationRecord
end
```

Typically:

```text
User      → users table
User      → one row represented as a User object
attributes → database columns
```

Example:

```ruby
user = User.find(1)

user.id
user.email
user.save
user.destroy
```

The `user` variable is a `User` object, not a Hash.

---

# 2. Model and Active Record Objects

## 2.1 ApplicationRecord

Rails applications commonly define:

```ruby
class ApplicationRecord < ActiveRecord::Base
end
```

Models inherit from it:

```ruby
class User < ApplicationRecord
end
```

This gives the model Active Record functionality.

---

## 2.2 Active Record Object

```ruby
user = User.find(1)
```

The result is:

```ruby
user.class
# => User
```

Ruby may display:

```text
#<User:0x000000011454c3a0>
```

This is Ruby's object inspection representation.

It is **not**:

- a Hash
- a database row itself
- the user's ID
- JSON

The data is accessible through the object:

```ruby
user.id
user.email
user.attributes
```

---

## 2.3 Hash

A Hash uses `{}`:

```ruby
{
  "id" => 1,
  "email" => "user@example.com"
}
```

or:

```ruby
{
  id: 1,
  email: "user@example.com"
}
```

Both are Hashes.

```ruby
user.attributes.class
# => Hash
```

---

# 3. ActiveRecord::Relation and Lazy Loading

A query such as:

```ruby
users = User.where(status: :active)
```

normally produces:

```ruby
users.class
# => ActiveRecord::Relation
```

A relation represents a composable query.

Conceptually:

```text
User.where(...)
       ↓
ActiveRecord::Relation
       ↓
SQL query
       ↓
Database
       ↓
User objects
```

## 3.1 Lazy loading

Many query-building operations do not immediately load all records:

```ruby
users = User.where(status: :active)
users = users.order(created_at: :desc)
users = users.limit(10)
```

The query can be built progressively.

Operations such as:

```ruby
users.to_a
users.each
users.map { |user| user.email }
```

can cause records to be loaded.

However, not every method loads all records.

For example:

```ruby
User.where(active: true).count
```

can execute a database aggregation such as:

```sql
SELECT COUNT(*)
FROM users
WHERE active = true
```

Other examples:

```ruby
exists?
pluck
pick
sum
average
minimum
maximum
```

may query the database directly without instantiating every record.

---

# 4. CRUD and Persistence

## 4.1 Create

### `new`

```ruby
user = User.new(
  name: "Loc",
  email: "loc@example.com"
)
```

Creates a Ruby object but does not persist it.

### `create`

```ruby
user = User.create(
  name: "Loc",
  email: "loc@example.com"
)
```

Creates the object and attempts to persist it.

Conceptually:

```text
new
 ↓
Ruby object
 ↓
save
 ↓
INSERT
```

---

## 4.2 Read

Common methods:

```ruby
User.all
User.find(1)
User.find_by(email: "a@example.com")
User.first
User.last
```

---

## 4.3 Update

```ruby
user.update(name: "Steven")
```

or:

```ruby
user.name = "Steven"
user.save
```

---

## 4.4 Delete

```ruby
user.destroy
```

or:

```ruby
User.destroy(1)
```

`destroy` runs destroy callbacks and association behavior configured for destruction.

---

## 4.5 Bang Methods

Many persistence methods have bang versions:

```ruby
save!
create!
update!
destroy!
```

They raise an exception when the operation fails, whereas non-bang methods commonly return `false` on validation failure.

---

# 5. Query Interface

Active Record provides a Ruby DSL for building SQL queries.

## 5.1 Filtering

```ruby
User.where(status: :active)

User.where("age > ?", 18)

User.where.not(status: :inactive)
```

---

## 5.2 Ordering

```ruby
User.order(created_at: :desc)

User.reorder(created_at: :asc)

User.reverse_order
```

---

## 5.3 Pagination

```ruby
User.limit(10)
User.offset(20)
```

Cursor pagination can also be implemented using ordered columns and conditions rather than relying only on offset pagination.

---

## 5.4 Selecting Columns

```ruby
User.select(:id, :email)
```

This still returns Active Record model objects.

---

## 5.5 Joining

```ruby
User.joins(:wallet)
User.left_joins(:wallet)
```

These are useful when filtering or querying based on associated tables.

---

## 5.6 Grouping

```ruby
User.group(:status)
User.group(:status).count
```

---

## 5.7 Having

```ruby
User.group(:status).having("COUNT(*) > 10")
```

---

## 5.8 Query Composition

Relations can be chained:

```ruby
User
  .where(status: :active)
  .order(created_at: :desc)
  .limit(10)
```

This is one of the main strengths of `ActiveRecord::Relation`.

---

# 6. Scopes

A scope is a reusable query definition.

```ruby
class User < ApplicationRecord
  scope :active, -> {
    where(status: :active)
  }

  scope :recent, -> {
    order(created_at: :desc)
  }
end
```

Usage:

```ruby
User.active
User.recent
User.active.recent
```

Scopes normally return an `ActiveRecord::Relation`, making them chainable.

---

## 6.1 Scope with Arguments

```ruby
scope :by_status, ->(status) {
  where(status: status)
}
```

Usage:

```ruby
User.by_status(:active)
```

---

## 6.2 Merge

Relations and scopes can be composed using `merge`:

```ruby
User.active.merge(User.recent)
```

`merge` is especially useful when composing conditions from different relations.

---

## 6.3 `default_scope`

Rails also supports:

```ruby
default_scope { where(active: true) }
```

Use `default_scope` carefully because it implicitly affects many queries.

---

# 7. Associations

Associations describe relationships between models.

## 7.1 `belongs_to` / `has_one`

```ruby
class User < ApplicationRecord
  has_one :wallet
end

class Wallet < ApplicationRecord
  belongs_to :user
end
```

Conceptually:

```text
users
  1
  │
  │
  1
wallets
```

The foreign key normally lives on `wallets`:

```text
wallets.user_id
```

---

## 7.2 `has_many`

```ruby
class User < ApplicationRecord
  has_many :posts
end

class Post < ApplicationRecord
  belongs_to :user
end
```

Conceptually:

```text
User 1 ───── N Posts
```

---

## 7.3 Many-to-Many

Using a join model:

```ruby
class User < ApplicationRecord
  has_many :user_roles
  has_many :roles, through: :user_roles
end

class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role
end

class Role < ApplicationRecord
  has_many :user_roles
  has_many :users, through: :user_roles
end
```

Conceptually:

```text
User
 │
 └── UserRole ── Role
```

---

## 7.4 Other Association Concepts

Important advanced association topics:

```text
has_many :through
has_one :through
polymorphic associations
inverse_of
dependent
association callbacks
```

Example:

```ruby
has_many :posts, dependent: :destroy
```

---

# 8. Association Loading

Association access can cause additional queries.

```ruby
user.wallet
```

If the association is not already loaded, Rails may execute:

```sql
SELECT *
FROM wallets
WHERE user_id = 1
```

This is association lazy loading.

---

## 8.1 `includes`

```ruby
User.includes(:wallet)
```

Used for eager loading and commonly used to prevent N+1 queries.

---

## 8.2 `preload`

```ruby
User.preload(:wallet)
```

Typically loads the associations with separate queries.

---

## 8.3 `eager_load`

```ruby
User.eager_load(:wallet)
```

Typically uses a `LEFT OUTER JOIN`.

---

## 8.4 `joins`

```ruby
User.joins(:wallet)
```

Primarily creates SQL JOIN behavior for querying.

A useful mental model:

```text
joins
  → JOIN for querying

includes
  → eager loading

preload
  → separate eager-loading queries

eager_load
  → JOIN-based eager loading
```

---

# 9. Validation

Validation checks whether an Active Record object is valid before persistence.

```ruby
class User < ApplicationRecord
  validates :email, presence: true
  validates :username, uniqueness: true
end
```

---

## 9.1 Built-in Validations

Common validators include:

```text
presence
absence
length
format
numericality
uniqueness
inclusion
exclusion
comparison
acceptance
confirmation
```

---

## 9.2 Custom Validation Method

```ruby
validate :company_email

def company_email
  unless email&.end_with?("@company.com")
    errors.add(:email, "must be a company email")
  end
end
```

---

## 9.3 Custom Validator Class

A validator class is useful when the same validation logic is shared between models.

Conceptually:

```text
Model A ─┐
         ├── Custom Validator
Model B ─┘
```

---

## 9.4 Validation Context

Validation can be restricted to specific contexts:

```ruby
validates :email, presence: true, on: :create
```

Rails also supports custom validation contexts.

---

## 9.5 Checking Validation Without Saving

```ruby
user.valid?
```

Then:

```ruby
user.errors
```

This is a major difference from persistence callbacks.

---

# 10. Callbacks

Callbacks are lifecycle hooks executed at defined points in an Active Record object's lifecycle.

## 10.1 Initialization

```ruby
after_initialize
after_find
```

`after_initialize` runs after an Active Record object is initialized.

`after_find` runs when a record is loaded from the database.

---

## 10.2 Validation

```ruby
before_validation
after_validation
```

---

## 10.3 Save

```ruby
before_save
around_save
after_save
```

These apply to both create and update.

---

## 10.4 Create

```ruby
before_create
around_create
after_create
```

These apply specifically to creation.

---

## 10.5 Update

```ruby
before_update
around_update
after_update
```

These apply specifically to updates.

---

## 10.6 Destroy

```ruby
before_destroy
around_destroy
after_destroy
```

---

## 10.7 Commit and Rollback

```ruby
after_commit
after_rollback
```

`after_commit` runs after the transaction has successfully committed.

This is important for side effects that should happen only after database persistence is guaranteed.

---

## 10.8 Around Callbacks

An around callback wraps the operation:

```ruby
around_save do |record, block|
  # before operation

  block.call

  # after operation
end
```

The block represents continuation of the wrapped lifecycle operation.

---

# 11. Validation vs Callback

A useful distinction:

```text
Validation
→ Is the data valid?

Callback
→ What should happen during this lifecycle?
```

### Validation

```ruby
validates :email, presence: true
```

Validation is appropriate for business/data validity.

### Callback

```ruby
before_save :normalize_email
```

or:

```ruby
after_commit :clear_cache
```

Callbacks are appropriate for lifecycle-related behavior and side effects.

Examples:

```text
normalize data
create audit information
clear cache
publish an event
trigger a webhook
```

Callbacks can abort lifecycle processing with:

```ruby
throw :abort
```

Validation normally communicates failure through:

```ruby
errors.add(...)
```

and the persistence operation then fails.

---

# 12. Transactions

A transaction groups database operations into an atomic unit.

```ruby
User.transaction do
  user.save!
  wallet.save!
end
```

Conceptually:

```text
BEGIN
  User INSERT
  Wallet INSERT
COMMIT
```

If an exception causes rollback:

```text
BEGIN
  User INSERT
  Wallet INSERT
      ↓
   Exception
      ↓
ROLLBACK
```

This prevents partial persistence.

---

## 12.1 Transaction + Callbacks

A simplified lifecycle:

```text
before_validation
      ↓
validation
      ↓
after_validation
      ↓
before_save
      ↓
before_create / before_update
      ↓
INSERT / UPDATE
      ↓
after_create / after_update
      ↓
after_save
      ↓
COMMIT
      ↓
after_commit
```

If the transaction rolls back:

```text
ROLLBACK
   ↓
after_rollback
```

---

# 13. Dirty Tracking

Active Record tracks changes to model attributes.

```ruby
user.email = "new@example.com"
```

Useful APIs include:

```ruby
user.changed?
user.changes
```

For persisted changes, modern Rails provides APIs such as:

```ruby
user.saved_change_to_email?
```

This is useful in callbacks and auditing.

Example:

```ruby
after_update :notify_email_change

def notify_email_change
  return unless saved_change_to_email?

  # ...
end
```

---

# 14. Attributes and Data Representation

An Active Record object contains attributes mapped to database columns.

```ruby
user.id
user.email
user.created_at
```

To inspect attributes:

```ruby
user.attributes
```

Example:

```ruby
{
  "id" => 1,
  "email" => "loc@example.com",
  "created_at" => ...
}
```

This is a Hash.

---

# 15. Serialization and Serializers

Serialization is the process of transforming an object into a representation suitable for transport or storage.

A useful conceptual pipeline:

```text
ActiveRecord User
       ↓
Serializer / Representation layer
       ↓
Hash / JSON-compatible structure
       ↓
JSON
       ↓
HTTP response
```

---

## 15.1 `attributes`

```ruby
user.attributes
```

Returns a Hash containing model attributes.

---

## 15.2 `as_json`

```ruby
user.as_json
```

Returns a JSON-compatible representation, commonly as a Hash.

---

## 15.3 `to_json`

```ruby
user.to_json
```

Returns a JSON string.

Conceptually:

```text
user
 │
 ├── attributes → Hash
 │
 ├── as_json    → JSON-compatible Hash
 │
 └── to_json    → JSON String
```

---

## 15.4 Why Use a Serializer?

Suppose the database model contains:

```text
id
username
email
password_digest
remember_digest
created_at
updated_at
internal fields
```

An API may only need:

```json
{
  "id": 1,
  "username": "loc",
  "email": "loc@example.com"
}
```

A serializer can explicitly control:

- exposed fields
- field names
- transformations
- nested objects
- associations
- API response structure

This avoids exposing internal model attributes accidentally.

---

## 15.5 Serializer vs Serialization

They are related but different:

```text
Serialization
→ The transformation process

Serializer
→ The component/class responsible for defining that representation
```

Depending on the Rails project, serializers may be implemented manually or through a serializer library.

---

# 16. Select, Pluck, Pick and Aggregations

## 16.1 `select`

```ruby
User.select(:id, :email)
```

Still returns Active Record model objects.

---

## 16.2 `pluck`

```ruby
User.pluck(:id, :email)
```

Returns values directly, for example:

```ruby
[
  [1, "a@example.com"],
  [2, "b@example.com"]
]
```

It avoids instantiating full User objects.

---

## 16.3 `pick`

```ruby
User.where(id: 1).pick(:email)
```

Gets a value directly.

---

## 16.4 Aggregations

```ruby
User.count
User.sum(:points)
User.average(:age)
User.minimum(:age)
User.maximum(:age)
```

These are generally executed as database aggregations.

---

# 17. Enum

Active Record supports enums.

Example:

```ruby
class User < ApplicationRecord
  enum :status, {
    inactive: 0,
    active: 1
  }
end
```

This can provide methods and query scopes such as:

```ruby
user.active?
user.active!
User.active
```

---

# 18. Database Constraints

Active Record validation is not a replacement for database constraints.

Application-level validation:

```ruby
validates :email, uniqueness: true
```

Database-level integrity can be enforced with:

```text
UNIQUE INDEX
FOREIGN KEY
NOT NULL
CHECK
```

A robust design often uses both:

```text
Application
    ↓
ActiveRecord Validation
    ↓
Database Constraint
```

Why?

Two concurrent application processes can both pass an application-level uniqueness check before either writes.

A database unique constraint protects the final integrity.

---

# 19. Locking and Concurrency

Active Record supports optimistic and pessimistic locking.

## 19.1 Optimistic Locking

With a `lock_version` column:

```text
User A reads version 1
User B reads version 1

A updates
→ version 2

B tries to update
→ stale object error
```

This detects conflicting updates.

---

## 19.2 Pessimistic Locking

Example:

```ruby
user.with_lock do
  user.update!(balance: user.balance + 100)
end
```

The record is locked during the transaction.

Useful when concurrent updates must be serialized.

---

# 20. Batch Processing

Avoid loading a very large table into memory:

```ruby
User.all.each do |user|
  # ...
end
```

For large datasets, use:

```ruby
User.find_each do |user|
  # ...
end
```

or:

```ruby
User.find_in_batches do |users|
  # ...
end
```

This processes records in batches.

---

# 21. Performance and N+1

A common problem:

```ruby
users = User.all

users.each do |user|
  puts user.wallet.name
end
```

Potentially:

```text
1 query for users
N queries for wallets
```

This is an N+1 query problem.

Use eager loading:

```ruby
User.includes(:wallet)
```

Then:

```ruby
users.each do |user|
  puts user.wallet.name
end
```

can avoid the repeated association queries.

Other performance techniques:

```text
select
pluck
pick
find_each
indexes
query optimization
EXPLAIN
avoiding unnecessary object instantiation
```

---

# 22. Raw SQL

Active Record Query Interface should normally be preferred.

Safe parameterization:

```ruby
User.where("age > ?", 18)
```

Avoid string interpolation:

```ruby
# Bad
User.where("email = '#{params[:email]}'")
```

Prefer:

```ruby
# Good
User.where("email = ?", params[:email])
```

This protects against SQL injection.

Raw SQL is sometimes appropriate for complex database-specific queries.

---

# 23. Active Record Mental Model

A useful overall model:

```text
                         ActiveRecord
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
        Model                Query            Persistence
          │                   │                   │
          │            ActiveRecord::Relation      │
          │                   │              save/create
          │             where/order/join       update/destroy
          │                   │
     ┌────┼──────────┐        │
     │    │          │        │
Validation Callback Association
     │    │          │
     │    │          └── includes/preload
     │    │
     │    └── lifecycle
     │
     └── errors/context

                              ↓

                    Transaction / Database
                              ↓
                    Serialization / API
```

---

# 24. Learning Checklist

## ActiveRecord Fundamentals

- [ ] ActiveRecord ORM
- [ ] ApplicationRecord
- [ ] Model ↔ Table
- [ ] Object ↔ Row
- [ ] Attributes
- [ ] ActiveRecord::Relation
- [ ] Lazy loading

## CRUD / Persistence

- [ ] new
- [ ] create
- [ ] find
- [ ] find_by
- [ ] update
- [ ] save
- [ ] destroy
- [ ] bang methods (`!`)

## Query Interface

- [ ] where
- [ ] select
- [ ] order
- [ ] limit
- [ ] offset
- [ ] group
- [ ] having
- [ ] joins
- [ ] left_joins
- [ ] includes
- [ ] preload
- [ ] eager_load
- [ ] merge
- [ ] find_each
- [ ] find_in_batches

## Scope

- [ ] scope
- [ ] lambda / proc
- [ ] parameterized scopes
- [ ] chainable scopes
- [ ] default_scope
- [ ] unscoped
- [ ] merge scopes

## Associations

- [ ] belongs_to
- [ ] has_one
- [ ] has_many
- [ ] has_many :through
- [ ] has_one :through
- [ ] polymorphic associations
- [ ] inverse_of
- [ ] dependent
- [ ] association loading
- [ ] N+1

## Validation

- [ ] Built-in validations
- [ ] errors
- [ ] custom validation method
- [ ] custom validator
- [ ] validation context
- [ ] valid?
- [ ] invalid?
- [ ] save vs save!
- [ ] Validation vs DB constraints

## Callbacks

- [ ] before_validation
- [ ] after_validation
- [ ] before_save
- [ ] around_save
- [ ] after_save
- [ ] before_create
- [ ] around_create
- [ ] after_create
- [ ] before_update
- [ ] around_update
- [ ] after_update
- [ ] before_destroy
- [ ] around_destroy
- [ ] after_destroy
- [ ] after_commit
- [ ] after_rollback
- [ ] Callback ordering
- [ ] throw :abort

## Transactions

- [ ] transaction
- [ ] commit
- [ ] rollback
- [ ] nested transactions
- [ ] after_commit
- [ ] after_rollback
- [ ] locking

## Attributes / Data

- [ ] Attribute types
- [ ] attributes
- [ ] enum
- [ ] Dirty tracking
- [ ] changed?
- [ ] changes
- [ ] saved_change_to_*

## Serialization

- [ ] attributes
- [ ] as_json
- [ ] to_json
- [ ] Serializer pattern
- [ ] Response transformation
- [ ] Nested serialization
- [ ] Avoid exposing internal fields

## Performance

- [ ] N+1
- [ ] includes
- [ ] preload
- [ ] eager_load
- [ ] select
- [ ] pluck
- [ ] pick
- [ ] exists?
- [ ] count vs size vs length
- [ ] find_each
- [ ] indexes
- [ ] EXPLAIN
- [ ] Query optimization

## Database Integration

- [ ] Migrations
- [ ] Indexes
- [ ] Foreign keys
- [ ] Unique constraints
- [ ] NOT NULL
- [ ] CHECK constraints
- [ ] Transactions
- [ ] Raw SQL
- [ ] SQL injection prevention

---

# Recommended Learning Order

```text
Model
  ↓
Attributes / Object / Relation
  ↓
CRUD
  ↓
Query Interface
  ↓
Scope
  ↓
Association
  ↓
Validation
  ↓
Callback
  ↓
Transaction
  ↓
Dirty Tracking
  ↓
Serialization / Serializer
  ↓
N+1 / Performance
  ↓
Locking / Concurrency
  ↓
Database Constraints / Advanced SQL
```

The key mental model is:

> **Validation asks whether the data is valid. Callback defines what should happen during an object's lifecycle. Scope defines reusable queries. ActiveRecord::Relation represents composable queries. Persistence writes those changes to the database. Serialization transforms model data into an API-friendly representation.**
