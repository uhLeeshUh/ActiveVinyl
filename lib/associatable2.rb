require_relative 'associatable'

module Associatable

  def has_one_through(name, through_name, source_name)
    through_options = self.assoc_options[through_name]

    define_method(name) do
      source_options = through_options.model_class.assoc_options[source_name]

      assoc_object = DBConnection.execute(<<-SQL, self.id)
      SELECT
        #{source_options.table_name}.*
      FROM
        #{self.class.table_name}
      JOIN
        #{through_options.table_name}
        ON #{self.class.table_name}.#{through_options.foreign_key} = #{through_options.table_name}.id
      JOIN
        #{source_options.table_name}
        ON #{through_options.table_name}.#{source_options.foreign_key} = #{source_options.table_name}.id
      WHERE
        #{self.class.table_name}.id = ?
      SQL
      source_options.model_class.parse_all(assoc_object)[0]
    end

  end
end
