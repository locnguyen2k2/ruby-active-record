module Cache
  # extend ActiveSupport::Concern
  # included do
  #   cattr_accessor :cache_client, default: CacheImpl.new
  # end

  class CacheImpl < CachePort
    def get(key)
      result = Rails.cache.read(key)
      Rails.logger.debug "Cache hit: #{result.to_json}"
      return nil if result.nil?
      result.to_json
    end

    def fetch(key, expires_in = 60, &bock)
      started_at = Time.now.to_f.in_milliseconds.to_i
      item = Rails.cache.fetch(key, expires_in: expires_in) do
        begin
          yield
        rescue ActiveRecord::RecordNotFound => e
          Rails.logger.warn("[CACHE] Record not found: #{e.message}")
          raise Exceptions::BusinessException.new(MessageData::RECORD_NOT_FOUND)
        rescue => e
          Rails.logger.error("[CACHE] Failed to fetch key=#{key}: #{e.class} - #{e.message}")
          nil
        end
        ensure
      end
      Rails.logger.info("[CACHE_FETCHED_DURATION] #{(Time.now.to_f.in_milliseconds.to_i - started_at)}ms")
      item
    end

    def set(key, value, expires_in = 60)
      Rails.logger.debug "New Key: #{key}, Value: #{value.as_json}, expires_in: #{expires_in}"
      Rails.cache.write(
        key,
        value.as_json,
        expires_in: expires_in.seconds
      )
    end

    def delete(key)
      Rails.cache.delete(key)
    end
  end

  # def cache
  #   @cache ||= self.class.cache_client
  # end

  # class_methods do
  #   def cache
  #     cache_client
  #   end
  # end
end
