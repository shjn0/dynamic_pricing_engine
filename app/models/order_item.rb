class OrderItem
  include Mongoid::Document
  include Mongoid::Timestamps
  field :qty, type: Integer
  field :price_per_item, type: BigDecimal

  belongs_to :order
  belongs_to :product

  index({ order_id: 1, product_id: 1 }, { unique: true })

  validates :qty, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price_per_item, presence: true, numericality: { greater_than: 0 }

  def total_price
    (price_per_item * qty).round(2)
  end
end
