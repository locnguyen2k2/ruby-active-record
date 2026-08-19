class UserService < Cache::CacheImpl
  def by_id(id)
    key = "user:" + id.to_s
    fetch(key: key, expires_in: 60) do
      puts "[DB] Fetched"
      User.eager_load(:wallets, :role).where(id: id)
    end
  end
end
