# frozen_string_literal: true

module RegisterIngesterOc
  module Config
    SettingsStruct = Struct.new(
      :OC_HOST,
      :OC_USERNAME
    )

    SETTINGS = SettingsStruct.new(
      ENV.fetch('OPENCORPORATES_SFTP_HOST'),
      ENV.fetch('OPENCORPORATES_SFTP_USER')
    )

    AwsCredentialsStruct = Struct.new(
      :AWS_REGION,
      :AWS_ACCESS_KEY_ID,
      :AWS_SECRET_ACCESS_KEY
    )

    AWS_CREDENTIALS = AwsCredentialsStruct.new(
      ENV.fetch('BODS_AWS_REGION'),
      ENV.fetch('BODS_AWS_ACCESS_KEY_ID'),
      ENV.fetch('BODS_AWS_SECRET_ACCESS_KEY')
    )
  end
end
