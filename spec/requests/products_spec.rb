require 'rails_helper'

RSpec.describe "/products", type: :request do
  describe "GET /index" do
    it "renders a successful response" do
      create_list(:product, 10)
      get products_url, as: :json
      expect(response).to be_successful
      expect(response.parsed_body['data'].length).to eq(10)
      expect(response.parsed_body.dig('data', 0, 'attributes')).to include(
        'name',
        'category',
        'default_price',
        'dynamic_price',
        'qty'
      )
    end
  end

  describe "GET /show" do
    it "returns 404 if product not found" do
      get product_url(id: 'non-existent-id'), as: :json
      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to eq({ "error" => "Product not found." })
    end

    it "renders a successful response" do
      product = create(:product)
      get product_url(product), as: :json
      expect(response).to be_successful
      expect(response.parsed_body.dig('data', 'attributes', 'name')).to eq(product.name)
      expect(response.parsed_body.dig('data', 'attributes', 'category')).to eq(product.category)
      expect(response.parsed_body.dig('data', 'attributes', 'default_price')).to eq(product.default_price.to_s)
      expect(response.parsed_body.dig('data', 'attributes', 'dynamic_price')).to eq(product.dynamic_price.to_s)
      expect(response.parsed_body.dig('data', 'attributes', 'qty')).to eq(product.qty)
    end
  end
end
