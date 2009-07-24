# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_swankdb_session',
  :secret      => '4cd77a511ea8fc2e65fdb3935271fa80f03f7054e8dc938ac4082a03f4b4a9ac83c3f84edfa076414ecb53b8361050c8b79de32a0f0860d55c9042e5f1db3c9a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
