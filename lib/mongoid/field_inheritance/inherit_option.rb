Mongoid::Fields.option :inherit do |model, field, value|
  if field.name.in?(Mongoid::FieldInheritance::INVALID_FIELDS)
    fail ArgumentError, "Field cannot be inherited: #{field.name}"
  end
  model.inheritable_fields = model.inheritable_fields.merge(field.name => field)
end
