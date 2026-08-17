# Module: ActiveRecord Querying & Modeling
## Section 7.1 — Mastering ActiveRecord Associations

### 1. What Are Associations?
In Ruby on Rails, an **association** is a connection between two ActiveRecord models. Associations make common database operations much simpler and more intuitive in your code by allowing you to tie related models together without writing raw SQL `JOIN` statements or manually handling foreign keys.

Without associations:
```ruby
# Finding a book's author manually
@book = Book.find(1)
@author = Author.find(@book.author_id)

```

With associations:

```ruby
# Finding a book's author using ActiveRecord associations
@author = Book.find(1).author

```

---

### 2. The 6 Types of ActiveRecord Associations

Rails supports six primary association types:

| Association Type | Relationship Description | Foreign Key Location |
| --- | --- | --- |
| **`belongs_to`** | Direct 1-to-1 or Many-to-1 link to a parent model | **This model's table** (`parent_id`) |
| **`has_one`** | 1-to-1 relationship owned by this model | **Target model's table** (`this_model_id`) |
| **`has_many`** | 1-to-Many relationship | **Target model's table** (`this_model_id`) |
| **`has_many :through`** | Many-to-Many relationship (via Join Model) | **Join model's table** |
| **`has_one :through`** | 1-to-1 relationship shortcut via an intermediate model | **Intermediate/Target table** |
| **`has_and_belongs_to_many` (HABTM)** | Direct Many-to-Many relationship (no Join Model) | **Separate join table** (no primary key) |

---

### 3. Detailed Association Patterns

#### A. One-to-One (`has_one` / `belongs_to`)

Used when one record owns exactly one instance of another record.

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_one :profile, dependent: :destroy
end

# app/models/profile.rb
class Profile < ApplicationRecord
  belongs_to :user # Migration table requires `user_id` foreign key
end

```

> 🔑 **Golden Rule of Foreign Keys:** The model that declares `belongs_to` **MUST** contain the foreign key column (`user_id`) in its database table.

---

#### B. One-to-Many (`has_many` / `belongs_to`)

The most common association type in Rails applications.

```ruby
# app/models/author.rb
class Author < ApplicationRecord
  has_many :books, dependent: :destroy
end

# app/models/book.rb
class Book < ApplicationRecord
  belongs_to :author # Migration table requires `author_id` foreign key
end

```

---

#### C. Many-to-Many via Join Model (`has_many :through`) — *Recommended*

Used when two models have a Many-to-Many relationship and you need to store extra attributes on the connection itself (e.g., `role`, `joined_date`, `royalty_percentage`).

```ruby
# app/models/author.rb
class Author < ApplicationRecord
  has_many :authorships, dependent: :destroy
  has_many :books, through: :authorships
end

# app/models/authorship.rb (Join Model)
class Authorship < ApplicationRecord
  belongs_to :author # Requires `author_id`
  belongs_to :book   # Requires `book_id`
end

# app/models/book.rb
class Book < ApplicationRecord
  has_many :authorships, dependent: :destroy
  has_many :authors, through: :authorships
end

```

---

#### D. Direct Many-to-Many (`has_and_belongs_to_many` / HABTM)

Used **only** when two models have a Many-to-Many relationship with zero extra metadata on the join.

```ruby
# app/models/assembly.rb
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

# app/models/part.rb
class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end

```

> **Database Migration for HABTM:** Requires a join table named alphabetically (`assemblies_parts`) with **no primary key** (`id: false`):
> ```ruby
> create_table :assemblies_parts, id: false do |t|
>   t.belongs_to :assembly
>   t.belongs_to :part
> end
> 
> ```
>
>

---

### 4. Advanced Association Options

#### Custom Names & Class Mapping (`class_name`, `foreign_key`)

When the association name does not match the target model name, explicitly define the target class and foreign key.

```ruby
class Book < ApplicationRecord
  # Map 'publisher' association to the 'User' class
  belongs_to :publisher, class_name: 'User', foreign_key: 'publisher_id'
  
  # Map 'reviews' association to namespaced 'Book::Review'
  has_many :reviews, class_name: 'Book::Review'
end

```

#### Dependent Destruction Options (`dependent:`)

Controls what happens to child records when a parent record is deleted:

* **`:destroy`** — Instantiates all child records and calls their `.destroy` callbacks (triggers validation & cleanup).
* **`:delete_all`** — Deletes child records directly from the database with a single SQL query (bypasses callbacks).
* **`:nullify`** — Sets the foreign key column on child records to `NULL` (keeps children, removes connection).
* **`:restrict_with_error`** — Prevents deletion of the parent and adds an error if child records exist.

---

### 5. Polymorphic Associations

Polymorphic associations allow a single model to belong to multiple other models on a single association.

```ruby
# 1. Target interface model
# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
end

# 2. Models using the interface
# app/models/book.rb
class Book < ApplicationRecord
  has_many :comments, as: :commentable
end

# app/models/author.rb
class Author < ApplicationRecord
  has_many :comments, as: :commentable
end

```

#### Database Schema Requirements for Polymorphism:

The `comments` migration requires two columns: an ID column and a string Type column.

```ruby
create_table :comments do |t|
  t.text :body
  t.references :commentable, polymorphic: true # Creates commentable_id (integer) & commentable_type (string)
  t.timestamps
end

```

---

### 6. Summary Comparison Matrix

| Pattern | Association Declaration | Database Requirements | Primary Use Case |
| --- | --- | --- | --- |
| **1-to-1** | `has_one` / `belongs_to` | `child_id` on target table | Profiles, settings, unique single extensions |
| **1-to-Many** | `has_many` / `belongs_to` | `parent_id` on target table | Standard nested items (Authors $\rightarrow$ Books) |
| **Many-to-Many (`:through`)** | `has_many :through` | Separate join table with primary key | Rich relationships requiring extra attributes |
| **Many-to-Many (HABTM)** | `has_and_belongs_to_many` | Alphabetical join table (`id: false`) | Simple linkage with zero extra attributes |
| **Polymorphic** | `belongs_to :x, polymorphic: true` | `x_id` and `x_type` columns | Universal features like Comments, Likes, or Images |

```

<ElicitationsGroup message="Next steps for your ActiveRecord documentation suite:">
  <Elicitation label="Create a hands-on exercise set on ActiveRecord Associations" query="Create 4 practical code exercises with solutions testing students on setting up associations, custom foreign keys, dependent destroy, and polymorphic relationships."/>
  <Elicitation label="Add a section on N+1 Queries and eager loading (includes, preload, eager_load)" query="Write a self-learning documentation section explaining N+1 queries in ActiveRecord associations and how to resolve them using includes, preload, and eager_load."/>
</ElicitationsGroup>

```