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
      #   If no fields are given, all inheritable fields will be marked
      #   inherited.
      # @return [Array<String>] The fields that are marked inherited.
      # @raise [Mongoid::FieldInheritance::UninheritableError] Raises when a
      #   given field may not be inherited.
      def mark_inherited(*fields)
        fields = assert_valid_inherited_fields(fields)
        if fields.empty?
          self.inherited_fields = self.class.inheritable_fields.keys
        else
          self.inherited_fields = (inherited_fields + fields).uniq
        end
      end

      def inherit(options = {})
        self.inherited_fields = extract_inherited_fields_from_options(options)
        copy_fields_for_inheritance(parent, self)
        inherited_fields
      end

      def inherit!(options = {})
        inherit(options)
        save!
      end

      def mark_overridden(*fields)
        fields = assert_valid_inherited_fields(fields)
        if fields.empty?
          self.inherited_fields = []
        else
          self.inherited_fields -= fields
        end
      end

      def override(options = {})
        self.inherited_fields = self.class.inheritable_fields -
          extract_inherited_fields_from_options(options)
        inherited_fields
      end

      def override!(options = {})
        override(options)
        save!
      end

      private

      def assert_valid_inherited_fields(fields, sanitized = true)
        if sanitized
          fields = Mongoid::FieldInheritance.sanitize_field_names(fields)
        end
        invalid_fields = fields.select do |f|
          !f.in?(self.class.inheritable_fields)
        end
        return fields if invalid_fields.empty?
        fail Mongoid::FieldInheritance::UninheritableError.new(invalid_fields),
             "Field#{invalid_fields.many? ? 's are' : ' is'} not " \
             "inheritable: " + invalid_fields.join(', ')
      end

      def extract_inherited_fields_from_options(options)
        options.assert_valid_keys(:only, :except)
        fields =
          if options[:only] && options[:except]
            fail ArgumentError, ':only and :except cannot be specified at once'
          elsif options[:only]
            Mongoid::FieldInheritance.sanitize_field_names(options[:only])
          elsif options[:except]
            self.class.inheritable_fields -
            Mongoid::FieldInheritance.sanitize_field_names(options[:except])
          else
            self.class.inheritable_fields
          end
        assert_valid_inherited_fields(fields, false)
      end
    end
  end
end
