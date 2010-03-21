require 'net/http'
require 'uri'

module Rit

  class Plate
    DEFAULT_TIMEOUT = 5

    class << self

      def timeout
        if defined?(@timeout)
          @timeout
        else
          @timeout = defined?(RIT_TIMEOUT) ? RIT_TIMEOUT : DEFAULT_TIMEOUT
        end
      end

      def timeout=(val)
        @timeout = val
      end

      def get(layout_name, instance_name, plate_name, publish_time = nil)
        path = published_plate_path(layout_name, instance_name, plate_name, publish_time)
        Rails.logger.info "Publish from rit.: #{path.to_s}"
        res = http.send(:get, path)
        # ms = Benchmark.ms { res = http.send(:get, url.path) }
        # logger.info "--> %d %s (%d %.0fms)" % [result.code, result.message, result.body ? result.body.length : 0, ms]
        handle_response(res).body
      rescue Timeout::Error => e
        raise TimeoutError.new(e.message)
      end

      def published_plate_path(layout_name, instance_name, plate_name, publish_time = nil)
        if publish_time.nil? or RAILS_ENV == 'production'
          '/published/' + [layout_name, instance_name, plate_name].compact.join('/')
        else
          '/published_on/' + [layout_name, instance_name, plate_name, publish_time.to_i].compact.join('/')
        end
      end

      def http
        configure_http(new_http)
      end

      def new_http
        Net::HTTP.new(RIT_HOST, RIT_PORT)
      end

      def configure_http(http)
        # Net::HTTP timeouts default to 60 seconds.
        http.open_timeout = timeout
        http.read_timeout = timeout
        http
      end

      # Handles response and error codes from the remote service.
      def handle_response(response)
        case response.code.to_i
          when 200...400
            response
          when 404
            raise NotFoundError.new(response)
          else
            raise ConnectionError.new(response)
        end
      end
    end
  end


  class ConnectionError < StandardError
    def initialize(response=nil)
      @response = response
    end

    def to_s
      message = "Failed."
      unless @response.nil?
        message << "  Response code = #{@response.code}." if @response.respond_to?(:code)
        message << "  Response message = #{@response.message}." if @response.respond_to?(:message)
      end
      message
    end
  end

  class NotFoundError < ConnectionError; end
  class TimeoutError < ConnectionError; end


  module ControllerMethods

    # A safe method that attempts to render content from rit
    #
    # Arguments:
    # * layout_name: +String+
    #     The name of the rit layout
    # * instance_name: +String+
    #     The name of the rit instance (optional)
    # * plate_name: +String+
    #     The name of the rit plate
    #
    # Returns:
    #   Returns content or empty (string)
    def rit_plate(layout_name, instance_name, plate_name)
      Rit::Plate.get(layout_name, instance_name, plate_name, session[:preview_time])
    rescue Rit::ConnectionError, Rit::NotFoundError
      ''
    end

    # A method that attempts to render content from rit and if none found will raise an error
    #
    # Arguments:
    # * layout_name: +String+
    #     The name of the rit layout
    # * instance_name: +String+
    #     The name of the rit instance (optional)
    # * plate_name: +String+
    #     The name of the rit plate
    #
    # Returns:
    #   Returns content (string) or raises error if not found
    def rit_plate!(layout_name, instance_name, plate_name)
      Rit::Plate.get(layout_name, instance_name, plate_name, session[:preview_time])
    end
  end
end