module Mongoid
  module FieldInheritance
    ##
    # A module containing various methods to manage inheritance in a certain
    # document.
    #
    # @since 0.1.0
    module Management
      def mark_inherited(*fields)
        fields = assert_valid_inherited_fields(fields)
        if fields.empty?
          self.inherited_fields = self.class.inheritable_fields
        else
          self.inherited_fields = (inherited_fields + fields).uniq
        end
      end

      def mark_overridden(*fields)
        fields = assert_valid_inherited_fields(fields)
        if fields.empty?
          self.inherited_fields = []
        else
          self.inherited_fields -= fields
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

      def override(options = {})
        self.inherited_fields = self.class.inheritable_fields -
          extract_inherited_fields_from_options(options)
        mark_overridden(options)
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
        invalid_field = fields.detect do |f|
          !f.in?(self.class.inheritable_fields)
        end
        return fields unless invalid_field
        fail ArgumentError, "#{invalid_field} is not inheritable"
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
