# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
# require "active_record/railtie"
# require "active_storage/engine"
require 'action_controller/railtie'
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require 'action_view/railtie'
# require "action_cable/engine"
# require "sprockets/railtie"
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# JSONAPIError class for returning properly formatted errors in openapi
class JSONAPIError < Committee::ValidationError
  def error_body
    {
      errors: [
        { status: id, detail: message }
      ]
    }
  end

  def render
    [
      status,
      { 'Content-Type' => 'application/vnd.api+json' },
      [JSON.generate(error_body)]
    ]
  end
end

# Module surrounding Rails application
module DorIndexingApp
  # Entrypoint to Rails application
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Do not validate e.g. OKComputer routes using OpenAPI
    accept_proc = proc { |request| request.path.start_with?('/dor') }
    config.middleware.use Committee::Middleware::RequestValidation, schema_path: 'openapi.yml',
                                                                    strict: true,
                                                                    error_class: JSONAPIError,
                                                                    accept_request_filter: accept_proc,
                                                                    parse_response_by_content_type: false,
                                                                    query_hash_key: 'action_dispatch.request.query_parameters'

    # TODO: Uncomment when API returns JSON or when Committee allows validating plain-text responses
    #
    # config.middleware.use Committee::Middleware::ResponseValidation, schema_path: 'openapi.yml'

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
  end
end
