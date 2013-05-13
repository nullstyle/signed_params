module SignedParams
  class Railtie < Rails::Railtie
    initializer "signed_params.install_controller_methods" do |app|
      ActionController::Base.send(:include, SignedParams::ControllerMethods)
    end
  end
end