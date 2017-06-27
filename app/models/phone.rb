class Phone < ApplicationRecord
  has_one :order_item
  has_many :cart_items

  def self.search_algorithm(search)
    unless search.length <= 2
    where([(["phone_name LIKE ? OR brand_name LIKE ?"] * search.split.length).join(' OR ')] +
    search.split.flat_map{|x|["%" + x + "%"]*2})
    end
  end

  def self.checkbox_search(params_hash)
    where(params_hash.slice("brand_name", "os", "price_category"))
  end


end
