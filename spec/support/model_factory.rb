module ModelFactory
  extend self

  def create_basic_model(name = 'TempModel', &block)
    if Object.const_defined?(name)
      Object.send(:remove_const, name)
    end
    model = Class.new do
      def self.name
        @name
      end

      def self.name=(name)
        @name = name
      end
    end
    model.name = name
    Object.const_set(name, model)
    model.class_eval do
      include Mongoid::Document
    end
    model.class_eval(&block) if block_given?
    model
  end

  def create_model(name = 'TempModel', &block)
    create_basic_model(name) do
      include Mongoid::FieldInheritance
      class_eval(&block) if block_given?
    end
  end
end
