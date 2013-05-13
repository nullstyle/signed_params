require 'base64'
require 'active_support/json'
require 'openssl'

module SignedParams
  module Versions
    class One < Base
      DIGEST  = OpenSSL::Digest::Digest.new('sha1')

      # (see SignedParams::Versions::Base#verify)
      def verify(value, secret, encoded)
        unencoded      = begin
                            Base64.urlsafe_decode64(encoded)
                          rescue ArgumentError
                            return :format_error
                          end
        unpacked       = begin
                           ActiveSupport::JSON.decode(unencoded)
                         rescue MultiJson::LoadError
                           return :format_error
                         end

        sig       = unpacked["sig"]
        viewer_id = unpacked["vwr"]

        return :format_error if sig.blank? || viewer_id.blank?

        ks                   = key_string(secret, viewer_id)
        calculated_signature = signature(ks, value)
        
        if calculated_signature == sig
          viewer_id
        else
          :invalid_signature
        end
      end


      # (see SignedParams::Versions::Base#sign)
      def sign(value, secret, viewer_id)
        ks        = key_string(secret, viewer_id)
        sig       = signature(ks, value)
        unpacked  = {
                      "sig" => sig,
                      "vwr" => viewer_id
                    }
        unencoded = ActiveSupport::JSON.encode(unpacked)
        encoded   = Base64.urlsafe_encode64(unencoded)
        encoded
      end

      private
      # 
      # Combines the provided secret along with the signer_ids to create a key
      # which can be used to generate a param signature
      # 
      # @param  secret [String] the secret
      # @param  viewer_id [String] The viewer id
      # 
      # @return [String] [description]
      def key_string(secret, viewer_id)
        "#{secret} #{viewer_id}"
      end

      def signature(key, data)
        bytes = OpenSSL::HMAC.digest(DIGEST, key, data)
        Base64.urlsafe_encode64(bytes)
      end
    end
  end
end