class RosterpocalypseController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_read!, only: [:index, :show]
  before_action :authorize_update!, only: [:edit, :update]
  before_action :authorize_create!, only: [:new, :create]
  before_action :authorize_destroy!, only: [:destroy]
  before_action :set_page_title, only: [:show, :edit]

  rescue_from "AccessGranted::AccessDenied" do |exception|
    redirect_back fallback_location: root_path, alert: "You don't have permission to take this action."
  end

  protected

  def authorize_create!
    authorize! :create, model_class.constantize
  end

  def authorize_update!
    authorize! :update, send(set_method_symbol)
  end

  def authorize_read!
    authorize! :read, model_class.constantize
  end

  def authorize_destroy!
    authorize! :destroy, send(set_method_symbol)
  end

  def model_class
    controller_path.classify
  end

  def set_method_symbol
    "set_#{controller_path.singularize}".to_sym
  end

  def set_page_title
    @page_title = "#{model_class.to_s.titleize}: #{send(set_method_symbol).name}"
  end

end
