module ActiveRecord
  module ConnectionAdapters
    class AbstractMysqlAdapter < AbstractAdapter

      def native_database_types
        NATIVE_DATABASE_TYPES.merge({ enum: { name: 'enum' } })
      end

      alias __initialize_type_map initialize_type_map
      def initialize_type_map(m) # :nodoc:
        __initialize_type_map(m)

        m.register_type(%r(enum)i) do |sql_type|
          limit = sql_type[/^enum\((.+)\)/i, 1]
            .split(',').map{|enum| enum.strip[1..-2]}
          MysqlEnum.new(limit: limit)
        end
      end

      class MysqlEnum < MysqlString
        def type
          :enum
        end
      end
    end

    module SchemaStatements
      alias __type_to_sql_enum type_to_sql

      def type_to_sql(type, limit = nil, precision = nil, scale = nil) #:nodoc:
        if type == :enum
          native = native_database_types[type]
          column_type_sql = (native || {})[:name] || 'enum'
          column_type_sql << "(#{limit.map { |v| quote(v) }.join(',')})"
          column_type_sql
        else
          __type_to_sql_enum(type, limit, precision, scale)
        end
      end
    end

    class TableDefinition
      def enum(*args)
        options = args.extract_options!
        column_names = args
        column_names.each { |name| column(name, 'enum', options) }
      end
    end
  end
end
