module ApplicationHelper
  def active?(tag = nil)
    if tag.nil?
      if params[:tagged].nil?
        'active'
      else
        ''
      end
    elsif params[:tagged].present? && params[:tagged].include?(tag)
      'active'
    else
      ''
    end
  end

  def icon(icon, options = {})
    content_tag(:i, '', :class => "icon #{icon} #{options[:class]}")
  end
end
