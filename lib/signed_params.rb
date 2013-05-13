require "signed_params/version"
require 'active_support/core_ext/object/blank'

module SignedParams
  autoload :Signer, "signed_params/signer"
  autoload :Railtie, "signed_params/railtie"
  autoload :ControllerMethods, "signed_params/controller_methods"

  module Versions
    autoload :Base, "signed_params/versions/base"
    autoload :One, "signed_params/versions/one"
  end
end

require 'signed_params/railtie' if defined?(Rails)
