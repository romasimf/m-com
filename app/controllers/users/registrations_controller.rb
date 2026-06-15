class Users::RegistrationsController < Devise::RegistrationsController
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      bypass_sign_in resource, scope: resource_name
      redirect_to settings_path, notice: "Профиль обновлён"
    else
      clean_up_passwords resource
      set_minimum_password_length
      flash[:settings_errors] = resource.errors.full_messages
      redirect_to settings_path
    end
  end

  protected

  def update_resource(resource, params)
    resource.update_with_password(params)
  end

  def after_update_path_for(resource)
    settings_path
  end
end