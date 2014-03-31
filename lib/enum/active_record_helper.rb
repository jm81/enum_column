if defined?(Rails::Generator)
  module Rails
    module Generator
      class GeneratedAttribute
        def field_type_with_enumerated_attribute
          return (@field_type = :enum_select) if type == :enum
          field_type_without_enumerated_attribute
        end
        alias_method_chain :field_type, :enumerated_attribute
      end
    end
  end
end

if defined?(ActionView::Base)
  module ActionView
    module Helpers

      # form_options_helper.rb
      module FormOptionsHelper
        # def select
        def enum_select(object, method, options={}, html_options={})
          if defined?(ActionView::Base::Tags::Select) # Rails 4
            select_tag = Tags::Select.new(
              object, method, self, [], options, html_options
            )
            obj = select_tag.object
            choices = []
            if obj.respond_to?(method.to_sym)
              choices = obj.column_for_attribute(method)
            end
            Tags::Select.new(
              object, method, self, choices.limit, options, html_options
            ).render
          else # Rails 3
            InstanceTag.new(object, method, self, options.delete(:object))
              .to_enum_select_tag(options, html_options)
          end
        end
      end

      class InstanceTag
        def to_enum_select_tag(options, html_options={})
          if self.object.respond_to?(method_name.to_sym)
            column = self.object.column_for_attribute(method_name)
            if value = self.object.__send__(method_name.to_sym)
              options[:selected] ||= value.to_s
            elsif options[:include_blank].nil?
              options[:include_blank] = column.null
            end
          end
          to_select_tag(column.limit, options, html_options)
        end

        #initialize record_name, method, self
        if respond_to?(:to_tag)
          def to_tag_with_enumerated_attribute(options={})
            #look for an enum
            if column_type == :enum &&
               self.object.class.respond_to?(method_name.to_sym)
              to_enum_select_tag(options)
            else
              to_tag_without_enumerated_attribute(options)
            end
          end
          alias_method_chain :to_tag, :enumerated_attribute
        end
      end

      class FormBuilder
        def enum_select(method, options={}, html_options={})
          @template.enum_select(
            @object_name, method, objectify_options(options),
            @default_options.merge(html_options)
          )
        end
      end

    end
  end
end
