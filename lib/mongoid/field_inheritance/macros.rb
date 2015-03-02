module Mongoid
  module FieldInheritance
    ##
    # Module which encapsulates all kinds of macro methods.
    #
    # @since 0.1.0
    module Macros
      extend ActiveSupport::Concern

      included do
        class_attribute :inheritable_fields, :inheritance_options
        self.inheritable_fields = {}
        self.inheritance_options = { dependent: :destroy }
      end

      module ClassMethods
        ##
        # Allows defining options for inheritance.
        #
        # @option options [Symbol] :dependent Controls what to do with child
        #   documents when destroying the parent. Possible values are :delete
        #   and :destroy. Defaults to :destroy when nothing is defined.
        # @return [Hash] The inheritance options.
        #
        # @example
        #   class Product
        #     include Mongoid::Document
        #     include Mongoid::FieldInheritance
        #
        #     inheritable dependent: :delete_all
        #
        #     field :manufacturer, inherit: true
        #     field :name
        #   end
        def inheritable(options)
          options.assert_valid_keys(:dependent)
          self.inheritance_options = inheritance_options.merge(options)
        end
      end
    end
  end
end
