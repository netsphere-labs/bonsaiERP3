
# 収支リポートのモデル
class Report
  # form object
  #attr_reader :search

  # additional params
  #attr_reader :attrs

  
  def initialize(search, attrs = {})
    raise TypeError if !search.is_a?(DateRange)
    
    @search = search
    @attrs = attrs
  end

  
  def expenses_by_item
    conn.select_rows(sum_movement_details_sql(params(type: 'Expense') ) )
    .map {|v| ItemTransReport.new(*v)}
  end

  def incomes_by_item
    conn.select_rows(sum_movement_details_sql(params(type: 'Income') ) )
    .map {|v| ItemTransReport.new(*v)}
  end

  def total_expenses
    @total_expenses ||= begin
      tot = Expense.active.where(date: date_range)
      tot = tot.all_tags(*attrs[:tag_ids])  if any_tags?
      0 #tot.sum('(accounts.total - accounts.amount) * accounts.exchange_rate')
    end
  end

  def total_incomes
    @total_incomes ||= begin
      tot = Income.active.where(date: date_range)
      tot = tot.all_tags(*attrs[:tag_ids])  if any_tags?
                         0 # tot.sum('(accounts.total - accounts.amount) * accounts.exchange_rate')
    end
  end

  def incomes_dayli
    data = params(type: 'Income')
    @incomes_dayli ||= [] # conn.select_rows(dayli_sql(data)).map {|v| DailyReport.new(*v)}
  end

  def expenses_dayli
    data = params(type: 'Expense')
    @expenses_dayli ||= [] # conn.select_rows(dayli_sql(data)).map {|v| DailyReport.new(*v)}
  end

  def expenses_pecentage
    return 0 if total == 0
    @expenses_pecentage ||= 100 * (total_expenses / total)
  end

  def incomes_percentage
    return 0 if total == 0
    @incomes_pecentage ||= 100 * (total_incomes / total)
  end

  def total
    @total ||= total_incomes + total_expenses
  end

  def contacts_incomes
    @contacts_incomes ||= conn.select_rows(contacts_sql params(type: 'Income')).map {|v| ContactReport.new(*v)}
  end

  def contacts_expenses
    @contacts_expenses ||= conn.select_rows(contacts_sql params(type: 'Expense')).map {|v| ContactReport.new(*v)}
  end

  
private
  
  def offset
      @offset ||= attrs[:offset].to_i >= 0 ? attrs[:offset].to_i : 0
    end

    def limit
      @limit ||= attrs[:limit].to_i > 0 ? attrs[:limit].to_i : 10
    end

    def params(extra = {})
    ReportParams.new({offset: offset, limit: limit}.merge(extra))
    end

    def sum_movement_details_sql(data)
      <<-SQL
        SELECT i.id, i.name, SUM(d.price * d.quantity * a.exchange_rate) AS total
        FROM movement_details d JOIN items i ON (i.id = d.item_id)
        JOIN accounts a ON (a.id = d.account_id)
        WHERE a.type = '#{data.type}'
        AND a.state IN ('approved', 'paid')
        AND a.date BETWEEN '#{date_range.begin}' AND '#{date_range.last}'
        #{ tags_sql('i') }
        GROUP BY (i.id)
        ORDER BY total DESC
        OFFSET #{data.offset} LIMIT #{data.limit}
      SQL
    end

    def tags_sql(table)
      if any_tags?
        sanitize_sql_array ["AND #{table}.tag_ids @> ARRAY[?]", tag_ids]
      else
        ""
      end
    end

    def dayli_sql(data)
      <<-SQL
        SELECT SUM((a.total - a.amount) * a.exchange_rate) AS tot, a.date
        FROM accounts a
        WHERE a.type = '#{data.type}' and a.state IN ('approved', 'paid')
        AND a.date BETWEEN '#{date_range.begin}' AND '#{date_range.last}'
        GROUP BY a.date
        ORDER BY a.date
      SQL
    end

    def contacts_sql(data)
      <<-SQL
      SELECT c.matchcode, SUM((a.total - a.amount) * a.exchange_rate) AS tot
      FROM contacts c JOIN accounts a ON (a.contact_id=c.id and a.type='#{data.type}')
      WHERE a.date BETWEEN '#{ date_range.begin}' AND '#{ date_range.last}'
      GROUP BY c.id
      ORDER BY tot DESC OFFSET #{data.offset} LIMIT #{data.limit}
      SQL
    end

    def any_tags?
      tag_ids.is_a?(Array) && tag_ids.any?
    end

    def sanitize_sql_array(ary)
      ApplicationRecord.send :sanitize_sql_for_conditions, ary
    end

    def tag_ids
      attrs[:tag_ids]
    end

    def conn
      ApplicationRecord.connection
    end
end

class ReportParams < OpenStruct; end
