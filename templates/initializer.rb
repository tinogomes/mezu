Mezu.configure do |config|
  # Mezu application supports multiple translations itself.
  # To autoload all translations that you're using and that Mezu supports,
  # leave the following line uncommented. Otherwise, comment it and
  # run `rails generate mezu:copy_locales` to copy files to config/locales/
  #
  config.autoload_locales!

  # If authenticate block will be evaluated and should return
  # +true+ for authorized users.
  #
  # The block's context (+self+) will be the controller's instance.
  #
  # Example :
  # config.authenticate = proc {
  #   authenticate_or_request_with_http_basic do |username, password|
  #     username == "admin" and password == "APowerfulAdminPassword"
  #   end
  # }
  #
  config.authenticate = proc { true }
end
