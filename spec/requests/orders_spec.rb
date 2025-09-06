require 'rails_helper'

RSpec.describe "/orders", type: :request do
  let(:product1) { create(:product, qty: 10) }
  let(:product2) { create(:product) }

  describe "GET /index" do
    it "renders a successful response" do
      create_list(
        :order, 10, order_items_attributes: [ product: product1, qty: 1, price_per_item: product1.dynamic_price ]
      )

      get orders_url, as: :json

      expect(response).to be_successful
      expect(response.parsed_body['data'].length).to eq(10)
      expect(response.parsed_body.dig('data', 0, 'attributes', 'total_price')).to eq(product1.dynamic_price.to_s)

      first_order_item = response.parsed_body.dig('data', 0, 'attributes', 'order_items', 'data', 0, 'attributes')

      expect(first_order_item['product_id']).to eq(product1.id.to_s)
      expect(first_order_item['qty']).to eq(1)
      expect(first_order_item['price_per_item']).to eq(product1.dynamic_price.to_s)
      expect(first_order_item['total_price']).to eq(product1.dynamic_price.to_s)
    end
  end

  describe "GET /show" do
    let(:order) do
      create(
        :order, order_items_attributes: [
          { product: product1, qty: 2, price_per_item: product1.dynamic_price },
          { product: product2, qty: 3, price_per_item: product2.dynamic_price }
        ]
      )
    end
    let(:attributes) { response.parsed_body.dig('data', 'attributes') }
    let(:item1_attributes) do
      attributes.dig('order_items', 'data').find { |item|
        item.dig('attributes', 'product_id') == product1.id.to_s
      }['attributes']
    end
    let(:item2_attributes) do
      attributes.dig('order_items', 'data').find { |item|
        item.dig('attributes', 'product_id') == product2.id.to_s
      }['attributes']
    end
    let(:order_item1_price) { product1.dynamic_price * 2 }
    let(:order_item2_price) { product2.dynamic_price * 3 }

    it "renders a successful response" do
      get order_url(order), as: :json

      expect(response).to be_successful

      expect(item1_attributes['product_id']).to eq(product1.id.to_s)
      expect(item1_attributes['qty']).to eq(2)
      expect(item1_attributes['price_per_item']).to eq(product1.dynamic_price.to_s)
      expect(item1_attributes['total_price']).to eq(order_item1_price.to_s)
      expect(item2_attributes['product_id']).to eq(product2.id.to_s)
      expect(item2_attributes['qty']).to eq(3)
      expect(item2_attributes['price_per_item']).to eq(product2.dynamic_price.to_s)
      expect(item2_attributes['total_price']).to eq(order_item2_price.to_s)

      expect(attributes['total_price']).to eq((order_item1_price + order_item2_price).to_s)
    end
  end

  describe "POST /create" do
    it "returns out of stock error" do
      post orders_url, params: { order: { order_items_attributes: [ { product_id: product1.id, qty: 1000 } ] } },
                       as: :json

      expect(response.status).to eq(422)
      expect(response.parsed_body['errors']).to include({ "order_items" => [ "#{product1.id} is out of stock." ] })
    end

    context "with invalid parameters" do
      context "when qty is not provided" do
        it_behaves_like "invalid order items", -> { { product_id: product1.id } }
      end

      context "when product_id is not provided" do
        it_behaves_like "invalid order items", -> { { qty: 1 } }
      end
    end

    it "returns a successful response" do
      post orders_url, params: { order: { order_items_attributes: [ { product_id: product1.id, qty: 2 } ] } },
                       as: :json

      expect(response).to have_http_status(:created)
      expect(response.parsed_body.dig('data', 'attributes', 'total_price')).to eq((product1.dynamic_price * 2).to_s)

      order_item = response.parsed_body.dig('data', 'attributes', 'order_items', 'data', 0, 'attributes')

      expect(order_item['product_id']).to eq(product1.id.to_s)
      expect(order_item['qty']).to eq(2)
      expect(order_item['price_per_item']).to eq(product1.dynamic_price.to_s)
      expect(order_item['total_price']).to eq((product1.dynamic_price * 2).to_s)

      expect(product1.reload.qty).to eq(8)
    end

    it "does not oversell under concurrent requests" do
      threads = []
      responses = []
      wait_for_it  = true

      5.times do
        threads << Thread.new do
          true while wait_for_it

          post orders_url, params: { order: { order_items_attributes: [ { product_id: product1.id, qty: 3 } ] } },
                           as: :json
          responses << response.dup
        end
      end

      wait_for_it = false

      threads.each(&:join)

      successful_responses = responses.select { |res| res.status == 201 }
      failed_responses = responses.select { |res| res.status == 422 }

      expect(successful_responses.size).to eq(3)
      expect(failed_responses.size).to eq(2)
      expect(product1.reload.qty).to eq(1)
    end
  end
end
