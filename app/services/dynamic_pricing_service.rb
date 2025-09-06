class DynamicPricingService
  attr_reader :product, :competitor_product

  def initialize(product_id, competitor_product)
    @product = Product.in_stock.find_by(id: product_id)
    @change_percentage = 100.0
    @competitor_product = competitor_product
  end

  def call
    now = Time.current
    search_range_start = now.send("beginning_of_#{ENV['PURCHASE_SEARCH_PERIOD']}")
    search_range_end = now.send("end_of_#{ENV['PURCHASE_SEARCH_PERIOD']}")
    purchase_count = OrderItem.where(product_id: product.id, created_at: search_range_start..search_range_end).sum(:qty)
    if purchase_count >= ENV["THRESHOLD_FREQUENT_PURCHASE"].to_i
      @change_percentage += ENV["RATE_CHANGE_FREQUENT_PURCHASE"].to_i
    end
    @change_percentage += ENV["RATE_CHANGE_LOW_QTY"].to_i if product.qty < ENV["THRESHOLD_LOW_QTY"].to_i
    @change_percentage -= ENV["RATE_CHANGE_HIGH_QTY"].to_i if product.qty >= ENV["THRESHOLD_HIGH_QTY"].to_i

    new_price = (product.default_price * (@change_percentage / 100)).round(2)

    if competitor_product
      competitor_price = BigDecimal(competitor_product["price"])

      if new_price > competitor_price
        new_price = (competitor_price * (ENV["RATE_CHANGE_COMPETITOR"].to_i/100.0)).round(2)
      end
    end

    product.update(dynamic_price: new_price)
  end
end
