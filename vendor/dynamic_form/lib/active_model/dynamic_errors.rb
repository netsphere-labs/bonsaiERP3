module ActiveModel
  class Errors
    # Redefine the ActiveModel::Errors::full_messages method:
    #  Returns all the full error messages in an array. 'Base' messages are handled as usual.
    #  Non-base messages are prefixed with the attribute name as usual UNLESS 
    # (1) they begin with '^' in which case the attribute name is omitted.
    #     E.g. validates_acceptance_of :accepted_terms, :message => '^Please accept the terms of service'
    # (2) the message is a proc, in which case the proc is invoked on the model object.
    #     E.g. validates_presence_of :assessment_answer_option_id, 
    #     :message => Proc.new { |aa| "#{aa.label} (#{aa.group_label}) is required" }
    #     which gives an error message like:
    #     Rate (Accuracy) is required
    def full_messages
      full_messages = []

      each do |error|
        Array.wrap(error.message).each do |error_message|
          if error.attribute == :base
            full_messages << error_message
          else
            attr_name = error.attribute.to_s.gsub('.', '_').humanize
            attr_name = @base.class.human_attribute_name(error.attribute, :default => attr_name)
            options = { :default => "%{attribute} %{message}", :attribute => attr_name }

            if error_message =~ /^\^/
              options[:default] = "%{message}"
              full_messages << I18n.t(:"errors.dynamic_format", **options.merge(:message => error_message[1..-1]))
            elsif error_message.is_a? Proc
              options[:default] = "%{message}"
              full_messages << I18n.t(:"errors.dynamic_format", **options.merge(:message => error_message.call(@base)))
            else
              full_messages << I18n.t(:"errors.format", **options.merge(:message => error_message))
            end
          end
        end
      end

      full_messages
    end
  end
end

require 'active_support/i18n'
I18n.load_path << File.dirname(__FILE__) + '/locale/en.yml'
