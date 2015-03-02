module Mongoid
  module FieldInheritance
    ##
    # This module performs what to with descending documents on destruction.
    #
    # @since 0.1.0
    module Dependent
      extend ActiveSupport::Concern

      ##
      # Defines aliases for known strategies.
      STRATEGY_ALIASES = {
        delete_all: :delete,
        destroy_all: :destroy
      }

      included do
        before_destroy :handle_inherited_documents_on_destroy
      end

      protected

      ##
      # A hook that is responsible for removing documents that are inheriting
      # from the current one.
      #
      # @return [void]
      def handle_inherited_documents_on_destroy
        dependent = self.class.inheritance_options[:dependent]
        dependent = STRATEGY_ALIASES.fetch(dependent, dependent)
        strategy = dependent.to_s.classify
        unless self.class.const_defined?(strategy)
          fail ArgumentError, "Unknown dependency handling: #{dependent}"
        end
        self.class.const_get(strategy).call(self)
      end
    end
  end
end

require 'mongoid/field_inheritance/dependent/base'
require 'mongoid/field_inheritance/dependent/delete'
require 'mongoid/field_inheritance/dependent/destroy'
