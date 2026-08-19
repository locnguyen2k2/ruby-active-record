Rails.configuration.x.redis_config = {
  url: ENV.fetch("REDIS_URL", "redis://127.0.0.1:6379/0"),
  connect_timeout: 5,
  read_timeout: 1,
  write_timeout: 1,
  reconnect_attempts: 3
}.freeze

Rails.configuration.x.redis_pool = ConnectionPool.new(
  size: ENV.fetch("REDIS_POOL_SIZE", 10).to_i,
  timeout: 5
) do
  Redis.new(Rails.configuration.x.redis_config)
end

Rails.application.config.after_initialize do
  if RedisHelper.available?
    puts "[REDIS] Connection is established successfully"
  else
    puts "[REDIS] Connection is NOT established"
  end
end