module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module Quoting
      alias __quote_enum quote

      # Quote a symbol as a normal string. This will support quoting of
      # enumerated values.
      def quote(value, column = nil)
        if value.is_a?(Symbol)
          ActiveRecord::Base.send(:quote_bound_value, value.to_s)
        else
          __quote_enum(value, column)
        end
      end
    end
  end
end
