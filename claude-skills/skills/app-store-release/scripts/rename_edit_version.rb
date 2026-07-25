# Renames the editable (draft) App Store version string — e.g. when the ASC draft
# says 1.4 but the project's MARKETING_VERSION is 1.5. The draft version string must
# match the project version or the release lane can't find/select the uploaded build.
# Only touches PREPARE_FOR_SUBMISSION-style drafts; refuses if there is no edit version.
#
# Run from the iOS project root:
#   LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 bundle exec ruby <this file> <new_version> [bundle_id]

require "spaceship"

new_version = ARGV[0] or abort("usage: rename_edit_version.rb <new_version> [bundle_id]")
bundle_id = ARGV[1]
if bundle_id.nil? || bundle_id.empty?
  appfile = File.read("fastlane/Appfile") rescue abort("ERROR: no bundle_id arg and no fastlane/Appfile")
  bundle_id = appfile[/app_identifier[ (]+["']([^"']+)["']/, 1] or abort("ERROR: app_identifier not found in Appfile")
end

key_path = ENV["ASC_API_KEY_PATH"] || File.expand_path("~/.fastlane/key.json")
Spaceship::ConnectAPI.token = Spaceship::ConnectAPI::Token.from_json_file(key_path)

app = Spaceship::ConnectAPI::App.find(bundle_id) or abort("ERROR: app #{bundle_id} not found")
edit = app.get_edit_app_store_version or abort("ERROR: no editable version to rename")
puts "BEFORE: #{edit.version_string} (#{edit.app_store_state})"
if edit.version_string == new_version
  puts "ALREADY: draft is #{new_version}, nothing to do"
  exit 0
end
edit.update(attributes: { versionString: new_version })
edit = app.get_edit_app_store_version
puts "AFTER: #{edit.version_string} (#{edit.app_store_state})"
abort("ERROR: rename did not stick") unless edit.version_string == new_version
