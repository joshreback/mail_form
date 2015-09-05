module MailForm
  class Base
    include ActiveModel::Conversion        # Implements an ActiveModel compliant API using to_model, to_key,
                                           # to_param, and to_partial_path
    extend  ActiveModel::Naming            # Implements a method called model_name()
    extend  ActiveModel::Translation       # Adds I18n
    include ActiveModel::Validations       # Defines a method named errors, which returns a hash of arrays
    include ActiveModel::AttributeMethods  # Allows us to define behavior on all attributes at once

    include MailForm::Validators           # Allows us to write our own custom validators
    extend  ActiveModel::Callbacks

    define_model_callbacks :deliver        # Allows us to define callbacks with the same semantics as in ActiveRecord
                                           # i.e, before_#{method-name} and after_#{method-name}

    attribute_method_prefix 'clear_'
    attribute_method_suffix '?'

    class_attribute :attribute_names
    self.attribute_names = []

    def self.attributes(*names)
      attr_accessor(*names)
      define_attribute_methods(names)
      self.attribute_names += names
    end

    def persisted?
      false
    end

    def deliver
      if valid?
        # Run before/after callbacks
        run_callbacks(:deliver) do
          MailForm::Notifier.contact(self).deliver
        end
      else
        false
      end
    end

    protected

    def clear_attribute(attribute)
      send("#{attribute}=", nil)
    end

    def attribute?(attribute)
      send(attribute).present?
    end
  end
end