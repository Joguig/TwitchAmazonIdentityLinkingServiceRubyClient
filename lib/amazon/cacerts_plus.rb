# Patch OpenSSL to load a list of approved CAs into the OpenSSL trust store
#
# = Amazon PLUS External CAs =
#   - if you just need the Amazon CAs require 'amazon/cacerts' instead
#
# The list of external CAs is take from AmazonCACerts- if you think an
# additional external CA should be added, contact that package's owner
#
# See 'amazon/cacerts.rb' for usage

require 'amazon/cacerts'
require 'amazon/openssl_patch'
Amazon::OpensslPatch.load_trust_store(:amazon_and_external)
