# Module: ActiveRecord Querying
## Section 6.1 — Mastering ActiveRecord Scopes

### 1. What is a Scope?
In Ruby on Rails, a **scope** is a custom SQL query helper defined inside an ActiveRecord model. Scopes allow you to encapsulate frequently used database queries into clean, reusable, and self-documenting method calls.

#### Key Principles:
1. **Lazy Evaluation:** Calling a scope does **not** execute a database query immediately.
2. **Returns `ActiveRecord::Relation`:** A scope returns a query object (SQL definition), **not** an array of database records or loaded data.
3. **Chainability:** Because scopes return `ActiveRecord::Relation` objects, multiple scopes can be chained together into a single, optimized SQL query.

---

### 2. Anatomy of Scope Definition

A scope is defined using the `scope` macro, which takes a **name**, a **callable object (lambda/proc)**, and an optional **extension block (`&block`)**.

```ruby
class Book < ApplicationRecord
  #  Name        Body (Callable Lambda)
  #  ↓           ↓
  scope :recent, -> { where("created_at >= ?", 1.week.ago) }
  
  # Scope accepting parameters:
  scope :by_category, ->(category_name) { where(category: category_name) }

  # Scope with a custom extension block (&block):
  scope :published, -> { where(status: 'published') } do
    def total_revenue
      sum(:price)
    end
  end
end

```

#### Anatomy Breakdown

| Component | Description |
| --- | --- |
| **Name (`:symbol`)** | The method name used to invoke the scope (e.g., `Book.recent`). |
| **Body (`-> { ... }`)** | A lambda/proc that must return an `ActiveRecord::Relation` object. |
| **Parameters (`->(arg)`)** | Arguments passed dynamically into the scope lambda. |
| **Block (`&block`)** | An optional block attached at the end to add unique helper methods directly to the returned relation. |

---

### 3. Execution Behavior: SQL Query vs. Data

Understanding when SQL executes is critical when working with scopes.

```ruby
# 1. SCOPE CALL (No Database Interaction)
query = Book.published.recent
# Output: #<ActiveRecord::Relation [...]>
# NO SQL QUERY IS EXECUTED YET!

# 2. DATA EVALUATION (Triggers Database Query)
books = query.to_a 
# SQL Executed: 
# SELECT "books".* FROM "books" 
# WHERE "books"."status" = 'published' 
# AND "books"."created_at" >= '2026-08-02 17:00:00'

```

#### When Does the Query Actually Run?

ActiveRecord delays hitting the database until data is explicitly required:

* Iterating with `.each` or `.map`
* Converting to array with `.to_a`
* Explicit fetchers like `.first`, `.last`, `.find()`, or `.pluck()`
* Rendering records directly in a view template

---

### 4. Combining Scopes: Chaining & Merging (`.merge`)

#### A. Singular & Chained Scopes

Because every scope returns an `ActiveRecord::Relation`, you can chain multiple scopes seamlessly:

```ruby
# Chaining 3 scopes + a limit modifier
Book.published.by_category("Programming").recent.limit(10)

```

#### B. Merging Scopes Across Models (`.merge`)

When joining two associated models, use `.merge` to apply a scope defined on the joined model:

```ruby
class Author < ApplicationRecord
  has_many :books
  
  # Scope on Author model
  scope :verified, -> { where(verified: true) }
end

class Book < ApplicationRecord
  belongs_to :author
  
  # Scope on Book model
  scope :cheap, -> { where("price < ?", 20) }
end

# Find cheap books written ONLY by verified authors:
Book.cheap.joins(:author).merge(Author.verified)

# Generated SQL:
# SELECT "books".* FROM "books" 
# INNER JOIN "authors" ON "authors"."id" = "books"."author_id" 
# WHERE "books"."price" < 20.0 AND "authors"."verified" = true

```

---

### 5. Scopes vs. Class Methods

In Rails, scopes are syntactic sugar for class methods that return an `ActiveRecord::Relation`.

```ruby
# Scope Syntax
scope :published, -> { where(status: 'published') }

# Class Method Syntax (Does the exact same thing)
def self.published
  where(status: 'published')
end

```

#### Why Prefer `scope` Over Class Methods?

Scopes guarantee that an `ActiveRecord::Relation` is returned, even if a parameter evaluates to `nil` or `false`.

```ruby
# SAFE SCOPE: If author_id is nil, it returns Book.all (preserving chaining)
scope :by_author, ->(author_id) { where(author_id: author_id) if author_id.present? }

# Usage:
Book.by_author(nil).recent # Works! Returns all recent books.

# DANGEROUS CLASS METHOD:
def self.by_author(author_id)
  where(author_id: author_id) if author_id.present? # Returns NIL if false!
end

# Usage:
Book.by_author(nil).recent # CRASHES with NoMethodError for nil:NilClass

```

---

### 6. The `default_scope` Pattern (Use With Caution!)

A `default_scope` automatically applies a query constraint to **all** queries on that model across the entire application.

```ruby
class Book < ApplicationRecord
  # Automatically filters out soft-deleted records everywhere
  default_scope { where(deleted_at: nil) }
end

```

#### ⚠️ Warning: Why `default_scope` is Dangerous

1. **Hidden Constraints:** Developers will forget `default_scope` exists when writing raw queries or background jobs.
2. **Breaks Uniqueness Validations:** `validates :title, uniqueness: true` will check against non-deleted books only, allowing duplicate titles for soft-deleted records.
3. **Hard to Bypass:** Bypassing `default_scope` requires explicitly wrapping queries in `.unscoped`:

```ruby
# Ignores default_scope:
Book.unscoped.all

```

> **Best Practice:** Avoid `default_scope` for domain logic. Use explicit named scopes like `scope :active, -> { where(deleted_at: nil) }` instead.

---

### 7. Summary Reference Matrix

| Feature | Details |
| --- | --- |
| **Arguments** | `name` (Symbol), `body` (Proc/Lambda), `&block` (Optional relation extensions) |
| **Return Value** | `ActiveRecord::Relation` (SQL Query object, **not** loaded records) |
| **Evaluation** | **Lazy** (Query executes only when data is evaluated/iterated) |
| **Chaining** | Native support (`Model.scope_one.scope_two`) |
| **Cross-Model Joining** | `Model.joins(:relation).merge(RelationModel.scope_name)` |
| **Nil Protection** | Returns `ActiveRecord::Relation` (all records) if condition evaluates to `nil` |
