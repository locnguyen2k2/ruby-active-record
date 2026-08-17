## 1. Scope (Phạm Vi Truy Vấn)
Scope cho phép định nghĩa các truy vấn SQL thường dùng dưới dạng các phương thức có thể tái sử dụng xuyên suốt ứng dụng.

### Đặc điểm cốt lõi
* **Bản chất:** Luôn trả về một đối tượng `ActiveRecord::Relation`. Nhờ cơ chế **Lazy Loading**, Scope chưa thực thi câu lệnh SQL xuống database cho đến khi dữ liệu thực sự được truy cập (như khi gọi `.each`, `.to_a`, `.first`).
* **Khả năng kết hợp (Chainability):** Có thể chuỗi nhiều scope lại với nhau hoặc sử dụng `.merge()` để kết hợp các scope giữa các model liên quan.
* **Cú pháp chuẩn:** `scope :name, ->(args) { ... }` (Bao gồm tên scope, body dạng lambda/proc, và block xử lý).
* **Xử lý tham số `nil`:** Khi tham số truyền vào evaluated thành `nil` hoặc `false`, Scope tự động bỏ qua điều kiện đó và trả về `.all` (`ActiveRecord::Relation`), giúp chuỗi truy vấn không bị gãy.

### So sánh giữa Scope có tham số và Class Method

| Tiêu chí | Scope | Class Method (`def self.method_name`) |
| :--- | :--- | :--- |
| **Khi tham số bị `nil` / rỗng** | Tự động trả về `.all`, không làm gãy chuỗi truy vấn. | Thực thi đúng logic viết trong method. Nếu không chủ động check `if params.present?`, có thể sinh SQL `WHERE col IS NULL` hoặc trả về kết quả không mong muốn. |
| **Giá trị trả về** | Luôn luôn là `ActiveRecord::Relation`. | Tùy thuộc vào giá trị return của dòng lệnh cuối cùng trong method (có thể là `nil`, `Array`, hoặc `ActiveRecord::Relation`). |

---

## 2. Validation (Xác Thực Dữ Liệu)
Validation đảm bảo chỉ những dữ liệu hợp lệ mới được ghi (`create`) hoặc cập nhật (`update`) vào Database.

### Các loại Custom Validator
* **Custom Class Validator:** Kế thừa từ `ActiveModel::Validator` (xác thực toàn bộ object) hoặc `ActiveModel::EachValidator` (xác thực thuộc tính cụ thể). Thường được tách thành class riêng để tái sử dụng giữa nhiều models.
* **Custom Method Validator:** Định nghĩa một phương thức private ngay trong model để xác thực thuộc tính nội bộ.
* **Custom Context Validator:** Xác thực dữ liệu dựa trên ngữ cảnh hoặc hành động cụ thể (ví dụ: `on: :create`, `on: :custom_context`).

### Cú pháp sử dụng (Usage)
* `validates`: Dùng với các validator mặc định của Rails (`presence`, `uniqueness`, ...) hoặc các Custom Class Validator có tên kết thúc bằng suffix `Validator`.
* `validates_with`: Dùng để gọi các class kế thừa từ `ActiveModel::Validator`.
* `validate`: Dùng với Custom Method Validator và hỗ trợ truyền context (ví dụ: `validate :custom_method, on: :custom_context`).

### Phân biệt Validation và Callback Hooks
* **Validation:** Dùng để kiểm tra tính hợp lệ của dữ liệu trước khi chuẩn bị ghi vào DB.
* **Callback Hooks:** Dùng để biến đổi dữ liệu (data transformation) hoặc kích hoạt tác vụ phụ (trigger side-effects).
* **Thứ tự với DB Transaction:** Validation thực thi **trước khi** DB mở transaction (ngoại trừ các callback validation như `before_validation`).

---

## 3. Lifecycle Callback Hooks
Các phương thức callback tự động kích hoạt tại các thời điểm nhất định trong vòng đời của một đối tượng ActiveRecord.

### Danh sách các Callback chính
* `after_initialize`: Gọi ngay sau khi một đối tượng được khởi tạo trong bộ nhớ (dù qua `User.new` hay loaded từ DB). Không mở DB transaction.
* `after_find`: Gọi ngay sau khi một bản ghi được tải thành công từ DB. Không mở DB transaction.
* `before_validation` / `after_validation`: Gọi trước và sau khi quá trình xác thực diễn ra (nằm ngoài DB transaction).
* `before_save` / `after_save`: Gọi trước và sau khi ghi dữ liệu (áp dụng cho cả `create` lẫn `update`).
* `before_create` / `after_create`: Gọi trước và ngay sau khi bản ghi mới được `INSERT` vào DB.
* `before_update` / `after_update`: Gọi trước và ngay sau khi bản ghi hiện có được `UPDATE` vào DB.
* `after_commit`: Gọi sau khi transaction DB đã hoàn tất commit thành công (thích hợp và an toàn nhất để trigger Sidekiq Job, gửi Email, v.v.).
* `after_rollback`: Gọi ngay sau khi transaction DB gặp lỗi và thực hiện rollback.

### Luồng thực thi chuẩn khi save/create
1. `before_validation`
2. `after_validation`
3. **`---> MỞ DB TRANSACTION <---`**
4. `before_save` / `before_create`
5. Thực thi câu lệnh SQL (`INSERT` / `UPDATE`)
6. `after_create` / `after_save`
7. **`---> COMMIT TRANSACTION <---`**
8. `after_commit` / `after_rollback` (chạy bên ngoài transaction)

---

## 4. ActiveModel::Serializer (`gem "active_model_serializers"`)
Sử dụng để định dạng, tùy biến cấu trúc dữ liệu JSON/Array trước khi trả về Response cho Client.

### Đặc điểm & Sử dụng
* **Khởi tạo:** Sử dụng CLI `rails g serializer User` để tạo tệp định nghĩa các thuộc tính cần trả về của model `User`.
* **Separation of Concerns:** Tách biệt hoàn toàn logic định dạng và hiển thị dữ liệu ra khỏi Controller và Model.
* **Scope trong Serializer:** Cho phép truyền `scope` (mặc định là `current_user`) vào serializer để phân quyền hiển thị dữ liệu linh hoạt (ví dụ: người dùng thường xem ít trường hơn Admin, hoặc danh sách xem dạng tóm tắt còn trang detail xem dạng đầy đủ).

---

## 5. Associations (Mối Quan Hệ Giữa Các Model)
Association giúp thiết lập sơ đồ liên kết giữa các bảng trong CSDL một cách khai báo và mạch lạc.

### Các loại quan hệ
* **Cơ bản:** `belongs_to`, `has_one`, `has_many`, `has_and_belongs_to_many` (HABTM).
* **Nâng cao:**
  * `has_many :through`: Kết nối 2 model thông qua một model trung gian (khuyên dùng thay vì HABTM để mở rộng bảng liên kết về sau).
  * **Polymorphic Associations:** Cho phép một model thuộc về nhiều model khác nhau chỉ qua một liên kết duy nhất (ví dụ: Model `Comment` thuộc về cả `Post` và `Video`).
* **Xử lý phụ thuộc (`dependent` options):**
  * `dependent: :destroy`: Xóa các bản ghi con và kích hoạt callbacks của các con đó.
  * `dependent: :delete_all`: Xóa trực tiếp tất cả bản ghi con bằng 1 câu lệnh SQL mà không kích hoạt callbacks.
  * `dependent: :nullify`: Set khóa ngoại (`foreign_key`) của các bản ghi con thành `NULL`.

---

## 6. Querying & Performance Optimization (Tối Ưu Truy Vấn)
Tối ưu truy vấn giúp ngăn ngừa quá tải Database và nâng cao tốc độ phản hồi của hệ thống.

### Vấn đề N+1 Query & Giải pháp Eager Loading
N+1 Query xảy ra khi ứng dụng thực hiện 1 câu truy vấn để lấy N bản ghi, sau đó lại thực hiện thêm N câu truy vấn nữa để lấy dữ liệu liên quan.
* `includes`: Tự động quyết định giữa `preload` hoặc `eager_load` dựa trên câu truy vấn.
* `preload`: Thực thi 2 hoặc nhiều câu SQL riêng biệt để nạp dữ liệu liên quan vào bộ nhớ.
* `eager_load`: Dùng `LEFT OUTER JOIN` để lấy toàn bộ dữ liệu chính và dữ liệu liên quan trong 1 câu SQL duy nhất.
* `joins`: Dùng `INNER JOIN` khi chỉ muốn lọc dữ liệu dựa trên bảng liên quan mà không nạp các thuộc tính của bảng đó ra bộ nhớ.

### Xử lý dữ liệu lớn (Batch Processing)
Tránh dùng `.all.each` với bảng lớn vì sẽ nạp toàn bộ bản ghi vào RAM gây tràn bộ nhớ. Thay vào đó:
* `find_each`: Lấy từng lô (mặc định 1000 bản ghi) và iterate qua từng object.
* `find_in_batches`: Lấy từng lô bản ghi dưới dạng mảng để xử lý theo lô.

### Lựa chọn cột cần thiết
* `pluck`: Trả về mảng các giá trị trực tiếp từ SQL mà không khởi tạo các đối tượng ActiveRecord (rất nhanh và nhẹ RAM).
* `select`: Chỉ chọn các cột cụ thể trong câu SQL nhưng vẫn trả về các đối tượng ActiveRecord.

---

## 7. Migrations & Schema Management (Quản Lý Cơ Sở Dữ Liệu)
Migration đóng vai trò là hệ thống quản lý phiên bản (VCS) cho cơ sở dữ liệu.

### Kỹ thuật quản lý Migration
* **Phương thức `change`:** Dùng cho các thao tác căn bản (`create_table`, `add_column`), Rails tự động suy luận logic rollback khi run `db:rollback`.
* **Phương thức `up` & `down`:** Bắt buộc dùng khi thực hiện thay đổi phức tạp mà Rails không thể tự suy luận logic đảo ngược (như đổi kiểu dữ liệu, xóa cột có dữ liệu).
* **Đánh Index (`add_index`):** Cần thiết cho các cột thường xuyên dùng trong điều kiện `WHERE`, `JOIN`, `ORDER BY`, hoặc ràng buộc `unique` để tối ưu tốc độ truy vấn.
* **Zero-downtime Migration:** Áp dụng quy trình từng bước khi rename/remove cột trên môi trường Production (sử dụng `ignored_columns` trước khi drop) để tránh crash ứng dụng đang chạy.

---

## 8. Transactions (Giao Dịch Database)
Transaction đảm bảo tính toàn vẹn dữ liệu theo nguyên tắc ACID (Toàn bộ thao tác thành công, hoặc rollback tất cả nếu có bất kỳ lỗi nào xảy ra).

### Quy tắc làm việc với Transaction
* **Cú pháp:** `ActiveRecord::Base.transaction do ... end`.
* **Cơ chế Rollback:** Transaction chỉ rollback khi có **Ngoại lệ (Exception)** được bắn ra bên trong block.
  * Các phương thức trả về `false` như `save`, `update` **không làm rollback transaction**.
  * Phải sử dụng phương thức dạng bang `!` (`save!`, `update!`, `create!`) hoặc bắn ngoại lệ thủ công: `raise ActiveRecord::Rollback`.
* **Nested Transactions:** Dùng option `requires_new: true` để tạo SAVEPOINT cho các transaction lồng nhau.

---

## 9. Model Patterns: Enum, STI & Delegated Types
Các pattern thiết kế mô hình dữ liệu tích hợp sẵn trong ActiveRecord.

* **Enum:** Ánh xạ các số nguyên trong Database thành các chuỗi trạng thái ở layer code.
  * *Khai báo:* `enum status: { pending: 0, active: 1, archived: 2 }`
  * *Tự động hỗ trợ helper methods:* `user.active?`, `user.archived!` và scope `User.pending`.
* **Single Table Inheritance (STI):** Lưu trữ nhiều Subclass/Model có chung thuộc tính vào **cùng 1 bảng Database** (phân biệt dựa trên cột `type`).
* **Delegated Types:** Giải pháp thay thế STI (từ Rails 6.1+) giúp chia nhỏ bảng, tránh tình trạng 1 bảng STI phình to và chứa quá nhiều cột `NULL`.

---

## 10. Dynamic Finders & Modern Query Methods
Một số phương thức truy vấn tiện ích hiện đại giúp tối giản dòng code:

* `find_or_create_by` / `find_or_initialize_by`: Tìm bản ghi theo điều kiện, nếu không thấy thì tự động tạo mới / khởi tạo.
* `where.not(...)`: Truy vấn phủ định.
* `where.associated(...)`: Lọc các bản ghi có tồn tại quan hệ tương ứng.
* `where.missing(...)`: Lọc các bản ghi không có quan hệ tương ứng (thay thế cho `LEFT OUTER JOIN WHERE id IS NULL`).
* `insert_all` / `upsert_all`: Thao tác chèn/cập nhật hàng loạt (Bulk Insert/Upsert) trực tiếp ở level SQL, bỏ qua validations và callbacks để đạt hiệu năng tối đa.