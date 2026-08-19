module Cache
    class CachePort
    def get(key)
      raise NotImplementedError, "#{self.class} must implement #speak"
    end

    def set(key, value, expires_in = 60)
      raise NotImplementedError, "#{self.class} must implement #speak"
    end

    def fetch(key, expires_in = 60, &block)
      raise NotImplementedError, "#{self.class} must implement #speak"
    end

    def delete(key)
      raise NotImplementedError, "#{self.class} must implement #speak"
    end
    end
end
