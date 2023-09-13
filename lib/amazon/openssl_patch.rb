require 'openssl'
module Amazon
  module OpensslPatch
    
    # CA directories as hardcoded in AmazonCACerts-1.0
    CA_STORE_DIRECTORIES = {
      :amazon_only => 'cacerts',
      :amazon_and_external => 'internal_and_external_cacerts'
    }
    
    # Monkeypatch OpenSSL::X509::Store.set_default_paths
    # to load a custom trust store
    def self.load_trust_store(ca_store)
      OpenSSL::X509::Store.class_eval do
      
        alias_method :set_default_paths_without_amazon, :set_default_paths unless
                               method_defined? :set_default_paths_without_amazon
                               
        define_method(:set_default_paths) do
          set_default_paths_without_amazon
          Amazon::OpensslPatch.each_pem(CA_STORE_DIRECTORIES[ca_store]) do |file|
            add_file file
          end
        end
        
      end
    end
    
    # Enumerate PEM files from a given directory
    def self.each_pem(dir) # :yields: file_path
      cacerts = File.join(File.dirname(__FILE__),'etc', dir)
      puts cacerts.to_s
      Dir.foreach(cacerts) do |file|
        next unless file =~ /.pem\Z/i
        yield File.join(cacerts, file)
      end
    end
  end
end
