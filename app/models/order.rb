class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :order_items, dependent: :destroy

  accepts_nested_attributes_for :order_items

  validates :order_items, presence: true

  def transactional_save
    Mongoid.transaction do
      product_ids = order_items.pluck(:product_id).compact.uniq
      products = Product.where(:id.in => product_ids).to_a.index_by(&:id)

      order_items.each do |item|
        product = products[item.product_id]

        if product
          item.price_per_item = product.dynamic_price

          if item.qty
            doc = Product.where(id: item.product_id, :qty.gte => item.qty).find_one_and_update(
              { "$inc" => { qty: -item.qty } }, { return_document: :after, upsert: false }
            )

            unless doc
              errors.add(:order_items, :out_of_stock, product_id: item.product_id)
              raise Mongoid::Errors::Rollback
            end
          end
        end
      end

      save!
    rescue
      return false
    end
  end

  def total_price
    order_items.sum(&:total_price)
  end
end
