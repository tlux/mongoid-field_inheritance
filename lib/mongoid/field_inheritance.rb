require 'active_support/all'
require 'mongoid/tree'

module Mongoid
  module FieldInheritance
    extend ActiveSupport::Concern

    INVALID_FIELDS = %w(_id _type created_at updated_at c_at u_at)

    included do
      include Mongoid::Tree

      class_attribute :inheritable_fields, instance_accessor: false,
                                           instance_predicate: false
      self.inheritable_fields = []
    end

    module ClassMethods
      def inherits(*fields)
        fields = fields.flatten.map(&:to_s)
        fail ArgumentError, 'No inheritable fields defined' if fields.empty?
        if fields.any? { |f| f.in?(INVALID_FIELDS) }
          fail ArgumentError, 'Cannot inherit fields: ' +
                              INVALID_FIELDS.join(', ')
        end

        self.inheritable_fields += fields

        fields.each do |field|
          [self, *descendants].each do |klass|
            klass.class_eval <<-RUBY
              def #{field}_inherited?
                attribute_inherited?(:#{field})
              end
            RUBY
          end
        end
      end

      def reset_inheritance
        inheritable_fields.each do |field|
          [self, *descendants].each do |klass|
            if klass.instance_methods.include?(:"#{field}_inherited?")
              klass.send(:remove_method, :"#{field}_inherited?")
            end
          end
        end
        inheritable_fields.clear
      end
    end
  end
end
