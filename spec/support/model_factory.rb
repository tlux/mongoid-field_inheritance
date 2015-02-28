module ModelFactory
  extend self

  def create_model(&block)
    if Object.const_defined?('TempModel')
      Object.send(:remove_const, 'TempModel')
    end
    model = Class.new
    Object.const_set('TempModel', model)
    model.instance_exec do
      include Mongoid::Document
      include Mongoid::FieldInheritance

      def self.name
        'TempModel'
      end
    end
    model.instance_exec(&block) if block_given?
    model
  end
end
