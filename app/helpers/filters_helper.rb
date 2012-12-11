module FiltersHelper
  def filter_form_for(filter, *args, &block)
    options = args.extract_options!
    simple_form_for(filter, *(args << options.merge(builder: FilterFormBuilder)), &block)
  end

  class FilterFormBuilder < SimpleForm::FormBuilder
    include ActionView::Helpers::TagHelper

    attr_accessor :filter_selector, :output_buffer

    def input(attribute_name, options = {}, &block)
      options[:wrapper_html] ||= {}
      options[:wrapper_html].merge!(:class => 'span6')
      super
    end

    def input_plus_check_box(attribute_name, options = {})
      html = []

      html << input(attribute_name, options)
      html << selector_check_box(attribute_name)

      content_tag(:div, :class => 'row') do
        html.join("\n").html_safe
      end
    end

    # You'll have to use #filter_selector= to set the filter selector before
    # this will work.
    def selector_check_box(attribute_name, text = "Include?")
      content_tag(:div, :class => 'span1') do
        fields_for(filter_selector) do |fs|
          fs.label(attribute_name, text) +
            fs.check_box(attribute_name, :data => {:'filter-selector' => "filter_#{attribute_name}"})
        end
      end
    end
  end
end
