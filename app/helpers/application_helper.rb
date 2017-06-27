module ApplicationHelper

  def present model, model_klass = model.class
    klass = "#{model_klass}Presenter".constantize
    presenter = klass.new model, self
    yield presenter if block_given?
  end

  def title
    content_for?(:title) ? content_for(:title) : t('title')
  end

  def page_title page_title
    content_for(:title) { page_title + " - " + t('title') }
  end

  # Use with the same arguments as image_tag. Returns the same, except including
  # a full path in the src URL. Useful for templates that will be rendered into
  # emails etc.
  def absolute_image_tag(*args)
    raw(image_tag(*args).sub /src="(.*?)"/, "src=\"#{request.protocol}#{request.host_with_port}" + '\1"')
  end
end