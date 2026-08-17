module Timestamp
  def self.format_datetime(val)
    val.strftime("%Y-%m-%d %H:%M:%S")
  end
end
