class InitUpdatePriceJob < ApplicationJob
  queue_as :default

  def perform
    response = Net::HTTP.get_response(URI("https://sinatra-pricing-api.fly.dev/prices?api_key=demo123"))

    competitor_data = if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    else
      Rails.logger.error("[ERROR] #{response.message}")
      []
    end

    Product.in_stock.each do |product|
      UpdatePriceJob.perform_later(product.id.to_s, competitor_data.find { |data| data["name"] == product.name })
    end
  end
end
