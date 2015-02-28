class Product
  include Mongoid::Document
  include Mongoid::FieldInheritance
  include Mongoid::Timestamps::Updated

  field :manufacturer
  field :name, localize: true
  field :sku, type: Integer

  embeds_many :custom_properties
end

class Cellphone < Product
end
