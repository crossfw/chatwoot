class IpLookupService
  Result = Struct.new(:city, :country, :country_code, :isp, keyword_init: true)

  def perform(ip_address)
    return if ip_address.blank? || !ip_database_available?

    lookup_result = qqwry_database.query(ip_address)
    return unless lookup_result

    build_result(lookup_result)
  rescue Errno::ETIMEDOUT => e
    Rails.logger.warn "Exception: IP resolution failed :#{e.message}"
  end

  private

  def qqwry_database
    @qqwry_database ||= QQWry::Database.new(GeocoderConfiguration::LOOK_UP_DB.to_s)
  end

  def build_result(lookup_result)
    location = lookup_result.country&.strip

    Result.new(
      city: location,
      country: location,
      country_code: normalize_country_code(location),
      isp: lookup_result.area&.strip
    )
  end

  def normalize_country_code(location)
    location&.split&.first
  end

  def ip_database_available?
    File.exist?(GeocoderConfiguration::LOOK_UP_DB)
  end
end
