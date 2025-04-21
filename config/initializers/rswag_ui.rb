Rswag::Ui.configure do |c|
  # Define the Swagger endpoints for UI display.
  # NOTE: This will be renamed to `openapi_endpoint` in Rswag v3.0
  c.swagger_endpoint '/api-docs/v1/swagger.yaml', 'API V1 Docs'

  # Enable basic authentication if required (e.g., for private APIs).
  # c.basic_auth_enabled = true
  # c.basic_auth_credentials 'username', 'password'
end
