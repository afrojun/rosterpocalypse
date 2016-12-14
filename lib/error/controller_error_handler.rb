# Error module to Handle errors globally
# include Error::ControllerErrorHandler in application_controller.rb

module Error
  module ControllerErrorHandler
    def self.included clazz
      clazz.class_eval do
        rescue_from ActiveRecord::StatementInvalid do |e|
          respond :bad_request, 400, e.to_s[/ERROR:(.*)/]
        end
        rescue_from ActiveRecord::RecordNotFound do |e|
          respond :record_not_found, 404, e.to_s
        end
      end
    end

    private

    def respond(_error, _status, _message)
      Rails.logger.warn "Rescuing from controller error: [#{_error}, #{_status}] #{_message}"
      puts "Rescuing from controller error: [#{_error}, #{_status}] #{_message}"
      redirect_map = {
        "create" => :new,
        "update" => :edit
      }

      respond_to do |format|
        format.html { render redirect_map[params["action"]], alert: _message }
        format.json do
          render json: {
            status: _status,
            error: _error,
            message: _message
          }.as_json
        end
      end
    end

  end
end
