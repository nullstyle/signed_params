module SignedParams
  class Signer
    VERSIONS = {
      1 => Versions::One.new
    }


    # 
    # Creates a new signer object for the specified key
    # @param  secret [String] the key all params will be signed with/verified against
    # 
    def initialize(secret, default_version=1)
      @secret = secret
      @default_version = default_version
    end

    # 
    # Provided a hash which contains values that may or may not
    # be encrypted using this system, the method finds such values,
    # decrypts them (overwriting the signed values) using the provided 
    # secret and returns the signing entities as an array of eids
    # 
    # @param  params [Hash] the params
    # 
    # @return [Array<(String, String, String, Symbol>] A manifest of verification results
    def verify_params(params)
      params.map do |(key, signed_value)|
        next unless signed_value.is_a?(String)
        [key] + verify(signed_value)
      end
    end

    # 
    # Attempts to verify a single signed value
    # 
    # @param  signed_value [String] the encoded value
    # 
    # @return [(String, String, Symbol)] The value, the viewer, and the status.  value and viewer will be nil if the param was could not be verified
    def verify(signed_value)
      return failed_verify(:not_signed) unless signed_value.index(":")

      value, version, encoded = signed_value.split(":", 3)
      protocol = VERSIONS[version.to_i]

      return failed_verify(:invalid_version) if protocol.blank?
      result = protocol.verify(value, @secret, encoded)

      if result.is_a?(Symbol)
        failed_verify(result)
      else
        type, viewer = *result
        succeeded_verify(value, type, viewer)
      end
    end


    # 
    # Signs the provided value for the provided viewer
    # 
    # @param  value [String] the value to sign
    # @param  type [String] the semantic type string for the value
    # @param  viewer [String] the viewer
    # @param  version=@default_version [Fixnum] the version of the signing protocol to use
    # 
    # @return [String] the signed value
    def sign(value, type, viewer, version=@default_version)
      protocol = VERSIONS[version]
      raise ArgumentError, "Invalid version: #{version.inspect}"  if protocol.blank?
      signature = protocol.sign(value, @secret, type, viewer)
      "#{value}:#{version}:#{signature}"
    end

    private
    def failed_verify(error_code)
      [nil, nil, nil, error_code]
    end

    def succeeded_verify(value, type, viewer)
      [value, type, viewer, :success]
    end
  end
end