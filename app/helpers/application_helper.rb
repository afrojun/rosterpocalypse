module ApplicationHelper
  def present(model, model_klass = model.class)
    klass = "#{model_klass}Presenter".constantize
    presenter = klass.new model, self
    yield presenter if block_given?
  end

  def title
    content_for?(:title) ? content_for(:title) : t('title')
  end

  def page_title(page_title)
    content_for(:title) { page_title + ' - ' + t('title') }
  end
end
