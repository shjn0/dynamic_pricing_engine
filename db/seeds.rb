unless Product.exists?
  attributes = CSV.read(Rails.root.join("db", "inventory.csv"), headers: true).map do |row|
    {
      name: row["NAME"],
      category: row["CATEGORY"],
      default_price: row["DEFAULT_PRICE"],
      dynamic_price: row["DEFAULT_PRICE"],
      qty: row["QTY"]
    }
  end

  Product.create(attributes)
end
