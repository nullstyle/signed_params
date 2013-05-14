require 'active_support/concern'

module SignedParams
  module ControllerMethods
    extend ActiveSupport::Concern

    included do |base|
      base.send(:before_filter, :setup_for_signed_params)
    end

    private
    def verify_params!(signer)
      verification_results =  signer.verify_params(params)

      verification_results.each do |(key, value, type, viewer, status)|
        next if status == :not_signed

        if status == :success
          params[key] = value
          @signed_params_viewers[key] = viewer
          @signed_params_types[key] = type
        else
          @signing_errors[key] = status
        end
      end
    end

    def params_verified?
      @signing_errors.any?
    end

    # 
    # Simple signed param check, ensuring the param at `key` was signed with the provided type and viewer
    # 
    # @param  key [String,Symbol] The param to check
    # @param  type [String] the expected type of the param value
    # @param  viewer [String] the expected viewer id of the param
    # 
    # @return [Boolean] true if the param was signed with the provided type and viewer, false if not
    def signed_param?(key, type, viewer)
      @signed_params_viewers[key] == viewer &&
      @signed_params_types[key] == type
    end

    def setup_for_signed_params
      @signed_params_viewers = {}.with_indifferent_access
      @signed_params_types = {}.with_indifferent_access
      @signing_errors = {}.with_indifferent_access
    end

    attr_reader :signing_errors
    attr_reader :signed_params_viewers
    attr_reader :signed_params_types
  end
end