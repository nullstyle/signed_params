module SignedParams
  module Versions
    class Base


      # 
      # Verifies the provided value against the encoded signature
      # and provided key
      # 
      # @param  value [String] the value to verify
      # @param  secret [String] the secret
      # @param  encoded [String] the encoded signature portion
      # 
      # @return [(String,String), Symbol] Either an error message symbol, or a 2-element array, containing the value type and viewer embedded within the signature
      def verify(value, secret, encoded)
        raise NotImplementedError
      end


      # 
      # Signs the provided value with the provided secret, for the
      # provided viewer
      # 
      # @param  value [String] the value to sign
      # @param  secret [String] the secret to use
      # @param  secret [String] the type of the value
      # @param  viewer [String] the viewer id who this signed value will be transmitted to
      # 
      # @return [String] the signature
      def sign(value, secret, type, viewer)
        raise NotImplementedError
      end

    end
  end
end