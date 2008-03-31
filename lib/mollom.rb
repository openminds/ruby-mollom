require 'xmlrpc/client'
require 'openssl'
require 'base64'

class Mollom
  API_VERSION = '1.0'

  attr_accessor :private_key, :public_key

  def initialize options = {}
    @private_key = options[:private_key]
    @public_key = options[:public_key]
  end

  def server_list
    @server_list ||= XMLRPC::Client.new("xmlrpc.mollom.com", "/#{API_VERSION}").call('mollom.getServerList', authentication_hash)
  end

  #  private
  def authentication_hash
    now = Time.now.gmtime.strftime('%Y-%m-%dT%H:%M:%S.000+0000')
    
    hash = Base64.encode64(
      OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new, @private_key, now)
    )
    
    return :public_key=> @public_key, :time => now, :hash => hash
  end
end