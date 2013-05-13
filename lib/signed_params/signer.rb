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
    # 
    def verify_params(params)
      params.map do |(key, value)|
        value, viewer, status = verify(value)
        [key, value, viewer, status]
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
        succeeded_verify(value, result)
      end
    end

    def sign(value, viewer, version=@default_version)
      protocol = VERSIONS[version]
      raise ArgumentError("Invalid version: #{version.inspect}")  if protocol.blank?
      signature = protocol.sign(value, @secret, viewer)
      "#{value}:#{version}:#{signature}"
    end

    private
    def failed_verify(error_code)
      [nil, nil, error_code]
    end

    def succeeded_verify(value, viewer)
      [value, viewer, :success]
    end
  end
end