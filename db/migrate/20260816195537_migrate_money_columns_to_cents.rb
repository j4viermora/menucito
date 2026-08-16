class MigrateMoneyColumnsToCents < ActiveRecord::Migration[8.1]
  # table => { column => { null:, default: } }
  COLUMNS = {
    cash_movements: { amount: { null: false, default: nil } },
    cash_sessions: {
      counted_amount: { null: true, default: nil },
      expected_amount: { null: true, default: nil },
      difference_amount: { null: true, default: nil },
      opening_amount: { null: false, default: "0.0" }
    },
    menu_items: { price: { null: false, default: nil } },
    order_items: { unit_price: { null: false, default: nil } },
    orders: {
      discount_amount: { null: false, default: "0.0" },
      subtotal: { null: false, default: "0.0" },
      total: { null: false, default: "0.0" }
    },
    payments: { amount: { null: false, default: nil } }
  }.freeze

  def up
    COLUMNS.each do |table, columns|
      columns.each_key do |column|
        add_column table, "#{column}_cents", :bigint
        execute "UPDATE #{table} SET #{column}_cents = ROUND(#{column} * 100) WHERE #{column} IS NOT NULL"
      end
    end

    COLUMNS.each do |table, columns|
      columns.each do |column, opts|
        cents_default = opts[:default] ? (opts[:default].to_f * 100).to_i : nil
        change_column_default table, "#{column}_cents", cents_default if cents_default
        change_column_null table, "#{column}_cents", false, cents_default if opts[:null] == false
        remove_column table, column
      end
    end
  end

  def down
    COLUMNS.each do |table, columns|
      columns.each_key do |column|
        add_column table, column, :decimal, precision: 12, scale: 2
        execute "UPDATE #{table} SET #{column} = #{column}_cents / 100.0 WHERE #{column}_cents IS NOT NULL"
      end
    end

    COLUMNS.each do |table, columns|
      columns.each do |column, opts|
        change_column_default table, column, opts[:default] if opts[:default]
        change_column_null table, column, false, opts[:default] if opts[:null] == false
        remove_column table, "#{column}_cents"
      end
    end
  end
end
