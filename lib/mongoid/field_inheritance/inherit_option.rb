Mongoid::Fields.option :inherit do |model, field, value|
  if field.name.in?(Mongoid::FieldInheritance::INVALID_FIELDS)
    fail Mongoid::FieldInheritance::UninheritableError.new(model, field),
         "Field is not inheritable: #{field.name}"
  end
  model.inheritable_fields = model.inheritable_fields.merge(field.name => field)
end
