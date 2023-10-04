# frozen_string_literal: true

require 'register_common/structs/aws_credentials'

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

    AWS_CREDENTIALS = RegisterCommon::AwsCredentials.new(
      ENV.fetch('BODS_AWS_REGION'),
      ENV.fetch('BODS_AWS_ACCESS_KEY_ID'),
      ENV.fetch('BODS_AWS_SECRET_ACCESS_KEY')
    )
  end
end
