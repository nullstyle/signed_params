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

      verification_results.each do |(key, value, viewer, status)|
        next if status == :not_signed

        if status == :success
          params[key] = value
          @signed_params_viewers[key] = viewer
        else
          @signing_errors[key] = status
        end
      end
    end

    def params_verified?
      @signing_errors.any?
    end

    def setup_for_signed_params
      @signed_params_viewers = {}
      @signing_errors = {}
    end

    def signing_errors
      @signing_errors
    end

    def signed_params_viewers
      @signed_params_viewers
    end

  end
end