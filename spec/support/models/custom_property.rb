class CustomProperty
  include Mongoid::Document

  embedded_in :product
end
