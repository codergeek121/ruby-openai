module OpenAI
  class Error < StandardError; end
  class ConfigurationError < Error; end

  class APIError < Error; end

  class InvalidAuthentication < APIError; end
  class ServerError < APIError; end
  class EngineOverload < APIError; end
  class TooManyRequests < APIError; end

  # https://platform.openai.com/docs/guides/error-codes/api-errors
  STATUS_CODE_ERROR_MAPPING = {
    401 => InvalidAuthentication,
    429 => TooManyRequests,
    500 => ServerError,
    503 => EngineOverload,
  }
  private_constant :ERROR_MAP

  module Errors
    class RaiseCustomErrors < Faraday::Middleware
      def on_complete(env)
        error_class = STATUS_CODE_ERROR_MAPPING.fetch(env.status) { APIError }
        raise error_class, { 
          status: env.status,
          headers: env.response.headers,
          body: env.body
        }
      end
    end
  end
end
