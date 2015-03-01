module Mongoid
  module FieldInheritance
    ##
    # A module containing various methods to manage inheritance in a certain
    # document.
    #
    # @since 0.1.0
    module Management
      ##
      # Marks all or certain fields in the document inherited. No values are
      # copied from the parent.
      #
      # @param [Array<Symbol, String>] fields The fields to be marked inherited.
      #   All inheritable fields will be marked inherited if no fields are
      #   given.
      # @return [Array<String>] The fields that are marked inherited.
      # @raise [Mongoid::FieldInheritance::UndefinedParentError] Raises when
      #   the document has no parent.
      # @raise [Mongoid::FieldInheritance::UninheritableError] Raises when a
      #   given field may not be inherited.
      def mark_inherited(*fields)
        fail UndefinedParentError.new(self), 'No parent defined' if root?
        fields = Mongoid::FieldInheritance.sanitize_field_names(fields)
        if fields.empty?
          self.inherited_fields = self.class.inheritable_fields.keys
        else
          self.inherited_fields =
            (inherited_fields + assert_valid_inherited_fields(fields)).uniq
        end
      end

      ##
      # Marks all or certain fields in the document inherited. Values are
      # copied from the parent.
      #
      # @option options [Array<String, Symbol>] :only The fields to inherit.
      # @option options [Array<String, Symbol>] :except The fields not to
      #   inherit. The document inherits all inheritable fields except the given
      #   ones.
      # @return [Array<String>] The fields that are marked inherited.
      # @raise [Mongoid::FieldInheritance::UndefinedParentError] Raises when
      #   the document has no parent.
      # @raise [Mongoid::FieldInheritance::UninheritableError] Raises when a
      #   given field may not be inherited.
      def inherit(options = {})
        fail UndefinedParentError.new(self), 'No parent defined' if root?
        self.inherited_fields = extract_inherited_fields_from_options(options)
        self.class.copy_fields_for_inheritance(parent, self)
        inherited_fields
      end

      ##
      # Behaves like {#inherit} and saves the document afterwards.
      #
      # @option options [Array<String, Symbol>] :only The fields to inherit.
      # @option options [Array<String, Symbol>] :except The fields not to
      #   inherit. The document inherits all inheritable fields except the given
      #   ones.
      # @return [Boolean] true when saving has been successful.
      # @raise [Mongoid::FieldInheritance::UndefinedParentError] Raises when
      #   the document has no parent.
      # @raise [Mongoid::FieldInheritance::UninheritableError] Raises when a
      #   given field may not be inherited.
      def inherit!(options = {})
        mark_inherited(extract_inherited_fields_from_options(options))
        save!
      end

      ##
      # Marks all or certain fields in the document overridden.
      #
      # @param [Array<Symbol, String>] fields The fields to be marked
      #   overridden. All inheritable fields will be marked overridden if no
      #   fields are given.
      # @return [Array<String>] The fields that are marked inherited.
      def mark_overridden(*fields)
        fields = Mongoid::FieldInheritance.sanitize_field_names(fields)
        if fields.empty?
          self.inherited_fields = []
        else
          self.inherited_fields -= fields
        end
      end

      ##
      # Marks all or certain fields in the document overridden.
      #
      # @option options [Array<String, Symbol>] :only The fields to override.
      # @option options [Array<String, Symbol>] :except The fields not to
      #   override. The document overrides all inheritable fields except the
      #   given ones.
      # @return [Array<String>] The fields that are marked inherited.
      def override(options = {})
        self.inherited_fields = self.class.inheritable_fields.keys -
          extract_inherited_fields_from_options(options)
        inherited_fields
      end

      ##
      # Behaves like {#override} and saves the document afterwards.
      #
      # @option options [Array<String, Symbol>] :only The fields to override.
      # @option options [Array<String, Symbol>] :except The fields not to
      #   override. The document overrides all inheritable fields except the
      #   given ones.
      # @return [Boolean] true when saving has been successful.
      def override!(options = {})
        override(options)
        save!
      end

      private

      def assert_valid_inherited_fields(fields)
        invalid_fields = fields.select do |f|
          !f.in?(self.class.inheritable_fields.keys)
        end
        return fields if invalid_fields.empty?
        fail UninheritableError.new(self, invalid_fields),
             "Field#{invalid_fields.many? ? 's are' : ' is'} not " \
             "inheritable: " + invalid_fields.join(', ')
      end

      def extract_inherited_fields_from_options(options)
        options.assert_valid_keys(:only, :except)
        if options[:only] && options[:except]
          fail ArgumentError, ':only and :except cannot be specified at once'
        elsif options[:only]
          Mongoid::FieldInheritance.sanitize_field_names(options[:only])
        elsif options[:except]
          self.class.inheritable_fields.keys -
          Mongoid::FieldInheritance.sanitize_field_names(options[:except])
        else
          self.class.inheritable_fields.keys
        end
      end
    end
  end
end
