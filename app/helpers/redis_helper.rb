module RedisHelper
  def self.with_redis(&block)
    Rails.configuration.x.redis_pool.with(&block)
  end

  def self.available?
    with_redis { |redis| redis.ping == "PONG" }
  rescue => e
    puts "[REDIS] PONG disabled #{e.class}: #{e.message}"
    false
  end

  def self.info
    with_redis { |redis| redis.info }
  end
end
