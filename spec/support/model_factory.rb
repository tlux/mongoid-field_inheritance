module ModelFactory
  extend self

  def create_model(name = 'TempModel', &block)
    if Object.const_defined?(name)
      Object.send(:remove_const, name)
    end
    model = Class.new do
      def self.name
        @@name
      end

      def self.name=(name)
        @@name = name
      end
    end
    model.name = name
    Object.const_set(name, model)
    model.instance_exec do
      include Mongoid::Document
      include Mongoid::FieldInheritance
    end
    model.instance_exec(&block) if block_given?
    model
  end
end
