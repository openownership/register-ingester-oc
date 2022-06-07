# frozen_string_literal: true

require_relative "lib/register_ingester_oc/version"

Gem::Specification.new do |spec|
  spec.name = "register_ingester_oc"
  spec.version = RegisterIngesterOc::VERSION
  spec.authors = ["Josh Williams"]
  spec.email = ["josh@spacesnottabs.com"]

  spec.summary = "Write a short summary, because RubyGems requires one."
  spec.description = "Write a longer description or delete this line."
  spec.homepage = "https://github.com/openownership/register_ingester_oc"
  spec.required_ruby_version = ">= 2.7"

  spec.metadata["allowed_push_host"] = "https://github.com/openownership/register_ingester_oc"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/openownership/register_ingester_oc"
  spec.metadata["changelog_uri"] = "https://github.com/openownership/register_ingester_oc"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'dotenv'

  spec.add_dependency 'net-sftp'
  spec.add_dependency 'ed25519', '~> 1'
  spec.add_dependency 'bcrypt_pbkdf', '~> 1'
  spec.add_dependency 'aws-sdk-s3', '~> 1.105.1'
end
