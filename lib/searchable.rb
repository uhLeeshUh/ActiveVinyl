require_relative 'db_connection'
require_relative 'sql_object'
require 'byebug'

module Searchable
  def where(params)
    keys = params.keys
    vals = params.values

    where_statement =
    keys.map do |key|
      "#{key} = ?"
    end

    where_statement = where_statement.join(" AND ")

    rows = DBConnection.execute(<<-SQL, *vals)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      #{where_statement}
    SQL

    self.parse_all(rows)
  end
end

class SQLObject
  extend Searchable
end
