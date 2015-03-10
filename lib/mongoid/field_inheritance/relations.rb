module Mongoid
  module FieldInheritance
    ##
    # Module which contains relation macro methods.
    #
    # @since 0.1.0
    module Relations
      extend ActiveSupport::Concern

      included do
        class << self
          alias_method_chain :belongs_to, :inheritance
        end
      end

      module ClassMethods
        # Adds a relational association from the child Document to a Document in
        # another database or collection.
        #
        # @example Define the relation.
        #
        #   class Game
        #     include Mongoid::Document
        #     belongs_to :person
        #   end
        #
        #   class Person
        #     include Mongoid::Document
        #     has_one :game
        #   end
        #
        # @param [Symbol] name The name of the relation.
        # @param [Hash] options The relation options.
        # @param [Proc] block Optional block for defining extensions.
        def belongs_to_with_inheritance(name, options = {}, &block)
          relation_opts = options.except(:inherit)
          meta = belongs_to_without_inheritance(name, relation_opts, &block)
          inherit(meta.foreign_key) if options.fetch(:inherit, false)
          meta
        end
      end
    end
  end
end
