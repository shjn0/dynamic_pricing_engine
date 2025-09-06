class Product
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :category, type: String
  field :default_price, type: BigDecimal
  field :dynamic_price, type: BigDecimal
  field :qty, type: Integer

  index({ name: 1, category: 1 }, { unique: true })

  scope :in_stock, -> { where(:qty.gt => 0) }
end
