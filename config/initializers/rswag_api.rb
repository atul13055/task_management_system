Rswag::Api.configure do |c|
  # Root folder where Swagger JSON files are located.
  # This is used by the Swagger middleware to serve requests for API descriptions.
  c.openapi_root = Rails.root.join('swagger').to_s

  # Optionally modify the Swagger response before serialization.
  # Example: Set the host dynamically from the request environment.
  # c.swagger_filter = -> (swagger, env) { swagger['host'] = env['HTTP_HOST'] }
end
