    Here is a complete, modular documentation section on **Model Namespacing in ActiveRecord**, formatted and structured for a self-learning guide.

---

# Module: ActiveRecord Architecture

## Section 4.2 — Namespacing Models (`Parent::Child`)

### 1. Overview

As Rails applications grow, the global scope in `app/models/` can quickly become crowded. Namespacing allows you to nest models inside Ruby modules or parent classes (e.g., `Book::Order`, `Payment::Transaction`).

This pattern solves three critical problems in large codebases:

1. **Prevents Naming Collisions:** Differentiates ambiguous terms like `Order` (e.g., `Customer::Order` vs. `Supplier::Order`).
2. **Defines Domain Boundaries:** Groups related models into clear sub-domains (Domain-Driven Design).
3. **Organizes the Directory Structure:** Replaces a flat list of 50+ files with clean subdirectories.

---

### 2. Directory & Class Structure

Rails uses **Zeitwerk** for autoloading. Zeitwerk requires the file path to strictly match the Ruby module and class constants.

#### File Layout

```text
app/
└── models/
    ├── book.rb           # Defines 'class Book' or 'module Book'
    └── book/
        ├── order.rb     # Defines 'class Book::Order'
        └── review.rb    # Defines 'class Book::Review'

```

#### Code Implementation

```ruby
# app/models/book.rb
class Book < ApplicationRecord
  has_many :orders, class_name: 'Book::Order'
  has_many :reviews, class_name: 'Book::Review'
end

# app/models/book/order.rb
module Book
  class Order < ApplicationRecord
    belongs_to :book
  end
end

```

> **Note on Syntax:** You can write `class Book::Order < ApplicationRecord` directly, provided the parent `Book` class or module is already loaded. Defining it using `module Book ... class Order` ensures the namespace scope is properly opened.

---

### 3. Database Conventions & Table Names

ActiveRecord calculates table names by converting the namespaced constant to `snake_case` and pluralizing the final word.

| Ruby Class | Default Table Name |
| --- | --- |
| `Book` | `books` |
| `Book::Order` | `book_orders` |
| `Inventory::WarehouseItem` | `inventory_warehouse_items` |

#### Generating Namespaced Models

You can generate a namespaced model directly from the command line:

```bash
bin/rails generate model Book::Order status:string total_price:decimal book:references

```

This command automatically generates:

* **Model:** `app/models/book/order.rb`
* **Migration:** Creating table `book_orders` with a foreign key column `book_id`

---

### 4. Setting Custom Table Prefixes

If you have multiple models under a single namespace module and want all their tables automatically prefixed in the database, define `self.table_name_prefix` in the module definition:

```ruby
# app/models/book.rb (defined as a Module instead of a Model)
module Book
  def self.table_name_prefix
    "book_"
  end
end

```

With this setting:

* `Book::Order` maps to `book_orders`
* `Book::Review` maps to `book_reviews`

---

### 5. Writing Associations Across Namespaces

When declaring associations between standard models and namespaced models, you must explicitly supply the `class_name` or `foreign_key` if Rails cannot infer it automatically.

#### Scenario A: Parent Has Many Namespaced Children

```ruby
class Book < ApplicationRecord
  # Explicit class_name is required because Rails would otherwise look for 'Order'
  has_many :orders, class_name: 'Book::Order'
end

class Book::Order < ApplicationRecord
  # Rails infers 'book_id' and 'Book' automatically from 'belongs_to :book'
  belongs_to :book
end

```

#### Scenario B: Cross-Namespace Associations

```ruby
class User < ApplicationRecord
  # A User placing a Book::Order
  has_many :book_orders, class_name: 'Book::Order'
end

class Book::Order < ApplicationRecord
  belongs_to :user
  belongs_to :book
end

```

---

### 6. Common Pitfalls & How to Avoid Them

#### 🛑 Pitfall 1: Unintended Namespace Shadowing

If you have a global model named `Order` AND a namespaced model `Book::Order`, referencing `Order` inside `Book::Order` will resolve locally to `Book::Order`, not the global `Order`.

* **Fix:** Use top-level scope syntax `::Order` when you need to reference the root `Order` model inside the namespace:

```ruby
module Book
  class Order < ApplicationRecord
    def copy_global_settings
      global_config = ::Order.default_settings # '::' forces top-level resolution
    end
  end
end

```

#### 🛑 Pitfall 2: Polymorphic Associations

When using polymorphic associations with namespaced models, ActiveRecord stores the full namespaced class string in the `_type` column (e.g., `"Book::Order"`).

```ruby
# Column: commentable_type = "Book::Order"
# Column: commentable_id = 12
Comment.create!(commentable: Book::Order.first, body: "Great order process")

```

* **Tip:** If you later rename the namespace module, you must run a database migration to update existing strings in `_type` columns.

---