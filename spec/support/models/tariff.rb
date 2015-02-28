class Tariff
  include Mongoid::Document
  include Mongoid::FieldInheritance

  field :name, localize: true, inherit: true
  field :product_number
end
