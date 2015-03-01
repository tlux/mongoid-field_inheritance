module Mongoid
  module FieldInheritance
    ##
    # This module performs what to with descending documents on destruction.
    #
    # @since 0.1.0
    module Dependency
      extend ActiveSupport::Concern

      ##
      # Defines aliases for known strategies.
      STRATEGY_ALIASES = {
        delete_all: :delete,
        destroy_all: :destroy
      }

      included do
        before_destroy :handle_inheriting_documents_on_destroy
      end

      protected

      ##
      # A hook that is responsible for removing documents that are inheriting
      # from the current one.
      #
      # @return [void]
      def handle_inheriting_documents_on_destroy
        strategy_name = self.class.inheritance_options[:dependent]
        strategy_name = STRATEGY_ALIASES.fetch(strategy_name, strategy_name)
        strategy_type = strategy_name.to_s.classify
        unless self.class.const_defined?(strategy_type)
          fail ArgumentError, "Unknown dependency handling: #{strategy_name}"
        end
        self.class.const_get(strategy_type).call(self)
      end
    end
  end
end

require 'mongoid/field_inheritance/dependency/base'
require 'mongoid/field_inheritance/dependency/delete'
require 'mongoid/field_inheritance/dependency/destroy'
