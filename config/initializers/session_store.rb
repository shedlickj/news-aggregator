# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_news-aggregator_session',
  :secret      => '89d41ee619fe183a7d1f1ae3075bf3d78b339081e2253888ebf78351a574d790fd5cef649ad4e986c25e026a3a52cfcd50c2bcfc28273beb9fbaf77a17c3f5a8'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
