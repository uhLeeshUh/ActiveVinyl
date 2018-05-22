require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || "#{name}".camelcase
  end

end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || "#{self_class_name.underscore}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || "#{name}".singularize.camelcase
  end

end

module Associatable
  def belongs_to(name, options = {})
    assoc_options[name] = BelongsToOptions.new(name, options)

    define_method(name) do
      foreign_key_id = self.send(self.class.assoc_options[name].foreign_key)
      self.class.assoc_options[name].model_class.find(foreign_key_id)
    end

  end

  def has_many(name, options = {})
    assoc_options[name] = HasManyOptions.new(name, self.to_s, options)

    define_method(name) do
      primary_key = self.send(self.class.assoc_options[name].primary_key)
      self.class.assoc_options[name].model_class.where(
        self.class.assoc_options[name].foreign_key => primary_key)
    end

  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
