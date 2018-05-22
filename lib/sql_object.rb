require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns

    @table_info ||= DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    columns = []
    @table_info[0].each do |col|
      columns << col.to_sym
    end
    columns
  end

  def self.finalize!
    columns.each do |col|
      define_method("#{col}=") do |arg|
        self.attributes[col] = arg
      end

      define_method("#{col}") do
        self.attributes[col]
      end

    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name = "#{self}".downcase + "s"
  end

  def self.all
    cols = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      SQL
      self.parse_all(cols)
  end

  def self.parse_all(results)
    objects = results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE id = ?
    SQL
    self.parse_all(result).first
  end

  def initialize(params = {})

    params.each do |attr_name, val|
      attr_name_sym = attr_name.to_sym
      raise "unknown attribute '#{attr_name_sym}'" unless self.class.columns.include?(attr_name_sym)
      self.send("#{attr_name}=", val)
    end

  end


  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |col|
      attributes[col]
    end
  end


  #make private
  def insert
    cols = attributes.keys.map(&:to_s).join(", ")
    vals = (["?"] * (self.class.columns.length - 1)).join(", ")
    passed_vals = attribute_values[1..-1]

    DBConnection.execute(<<-SQL, *passed_vals)
      INSERT INTO
        #{self.class.table_name} (#{cols})
      VALUES
        (#{vals})
    SQL
    self.id = DBConnection.last_insert_row_id
  end


  #make private
  def update
    cols = (self.attributes.keys - [:id]).map(&:to_s)

    new_cols = cols.join(" = ?, ")
    new_cols += " = ?"

    vals = []
    (self.attributes.keys - [:id]).each do |key|
      vals << attributes[key]
    end

    DBConnection.execute(<<-SQL, *vals, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{new_cols}
      WHERE
        id = ?
    SQL
  end

  def save
    if attributes[:id]
      update
    else
      insert
    end
  end
end
