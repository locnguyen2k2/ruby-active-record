# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_13_084709) do
  create_table "balances", id: uuid, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "created_by", limit: 36
    t.boolean "enable"
    t.datetime "updated_at", null: false
    t.string "user_id", limit: 36, null: false
    t.float "value"
    t.string "wallet_id", limit: 36, null: false
    t.index ["user_id"], name: "index_balances_on_user_id"
    t.index ["wallet_id"], name: "index_balances_on_wallet_id"
  end

  create_table "permissions", id: uuid, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "created_by", limit: 36
    t.boolean "enable"
    t.string "label"
    t.string "slug"
    t.datetime "updated_at", null: false
  end

  create_table "role_permissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "created_by", limit: 36
    t.string "permission_id", limit: 36, null: false
    t.string "role_id", limit: 36, null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", id: uuid, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "created_by", limit: 36
    t.boolean "enable"
    t.string "label"
    t.string "slug"
    t.datetime "updated_at", null: false
  end

  create_table "users", id: uuid, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "created_by", limit: 36
    t.string "email"
    t.boolean "enable"
    t.string "first_name"
    t.string "last_name"
    t.string "password_digest"
    t.string "remember_digest"
    t.string "role_id", limit: 36
    t.string "status"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  create_table "wallets", id: uuid, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "created_by", limit: 36
    t.text "description"
    t.boolean "enable"
    t.string "label"
    t.datetime "updated_at", null: false
    t.string "user_id", limit: 36, null: false
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "balances", "users"
  add_foreign_key "balances", "wallets"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "users", "roles"
  add_foreign_key "wallets", "users"
end
