RSpec.shared_examples "invalid order items" do |proc|
  let(:invalid_order_items, &proc)

  it "returns invalid order items errors" do
    post orders_url, params: { order: { order_items_attributes: [ invalid_order_items ] } }, as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body['errors']).to include({ "order_items" => [ "is invalid" ] })
  end
end
