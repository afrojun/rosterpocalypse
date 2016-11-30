module ApplicationHelper

  def present model
    klass = "#{model.class}Presenter".constantize
    presenter = klass.new model, self
    yield presenter if block_given?
  end

  def formatted_duration total_seconds
    hours = total_seconds / (60 * 60)
    minutes = (total_seconds / 60) % 60
    seconds = total_seconds % 60
    "#{ hours } h #{ minutes } m #{ seconds } s"
  end

end