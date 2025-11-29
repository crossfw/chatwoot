require 'fileutils'

class Geocoder::SetupService
  def perform
    return if File.exist?(GeocoderConfiguration::LOOK_UP_DB)

    log_info('Fetch QQWry IP database')
    download_database
  end

  private

  def download_database
    FileUtils.mkdir_p(File.dirname(GeocoderConfiguration::LOOK_UP_DB))
    Down.download(GeocoderConfiguration::DOWNLOAD_URL, destination: GeocoderConfiguration::LOOK_UP_DB.to_s)
    log_info('Fetch complete')
  rescue StandardError => e
    log_error(e.message)
  end

  def log_info(message)
    Rails.logger.info "[rake ip_lookup:setup] #{message}"
  end

  def log_error(message)
    Rails.logger.error "[rake ip_lookup:setup] #{message}"
  end
end
