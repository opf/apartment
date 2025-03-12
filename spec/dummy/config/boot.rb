# frozen_string_literal: true

require 'rubygems'
require "logger" # Fix concurrent-ruby removing logger dependency which Rails itself does not have


gemfile = File.expand_path('../../../Gemfile', __dir__)

if File.exist?(gemfile)
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler'
  Bundler.setup
end

$LOAD_PATH.unshift File.expand_path('../../../lib', __dir__)
