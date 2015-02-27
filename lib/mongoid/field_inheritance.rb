require 'active_support/concern'
require 'mongoid/tree'

module Mongoid
  module FieldInheritance
    extend ActiveSupport::Concern

    included do
      include Mongoid::Tree
    end
  end
end
