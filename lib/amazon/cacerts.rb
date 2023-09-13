# Patch OpenSSL to load a list of approved CAs into the OpenSSL trust store
#
# = Amazon CAs only =
#   - if you also require External CAs require 'amazon/cacerts_plus' instead
#
# This script patches OpenSSL::X509::Store to include the Amazon certs by
# default.  So all you have to do is require 'amazon/cacerts' and you're good
# to go.
#
# Usage:
#
#   = Using with OpenURI =
#
#     require 'open-uri'
#     require 'amazon/cacerts'
#     open('https://internal.amazon.com') do |f|
#     ...
#     end
#
#   = Using with Net::HTTP =
#
#   This is only slightly more involved.  You have to set the cert_store on the
#   Net::HTTP instance.  Example:
#
#     require 'net/https'
#     require 'amazon/cacerts'
#     http = Net::HTTP.new('internal.amazon.com', 443)
#     http.use_ssl = true
#     http.verify_mode = OpenSSL::SSL::VERIFY_PEER
#     store = OpenSSL::X509::Store.new
#     store.set_default_paths
#     http.cert_store = store

require 'amazon/openssl_patch'
Amazon::OpensslPatch.load_trust_store(:amazon_only)