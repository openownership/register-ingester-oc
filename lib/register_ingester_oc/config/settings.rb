require 'dotenv/load'

module RegisterIngesterOc
  module Config
    SettingsStruct = Struct.new(
      :OC_HOST,
      :OC_USERNAME,
      :OC_PASSWORD
    )

    SETTINGS = SettingsStruct.new(
      ENV.fetch('OPENCORPORATES_SFTP_HOST'),
      ENV.fetch('OPENCORPORATES_SFTP_USER'),
      ENV.fetch('OPENCORPORATES_SFTP_PASSWORD')
    )
  end
end
