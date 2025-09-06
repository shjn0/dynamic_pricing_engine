require "rails_helper"

RSpec.describe InitUpdatePriceJob, type: :job do
  let!(:product1) { create(:product, name: "MC Hammer Pants") }
  let!(:product2) { create(:product, name: "Nike Air") }
  let(:api_url) { "https://sinatra-pricing-api.fly.dev/prices?api_key=demo123" }

  context "when the API returns success" do
    let(:competitor_data) do
      [
        { "name" => "MC Hammer Pants", "category" => "Footwear", "price" => 3005.0, "qty" => 285 },
        { "name" => "Nike Air", "category" => "Footwear", "price" => 500.0, "qty" => 100 }
      ]
    end

    before do
      stub_request(:get, api_url)
        .to_return(status: 200, body: competitor_data.to_json, headers: { "Content-Type" => "application/json" })
    end

    it "enqueues UpdatePriceJob for each in-stock product" do
      expect { described_class.perform_now }.to have_enqueued_job(UpdatePriceJob).exactly(2).times

      expect(UpdatePriceJob).to have_been_enqueued.with(product1.id.to_s, competitor_data.first)
      expect(UpdatePriceJob).to have_been_enqueued.with(product2.id.to_s, competitor_data.second)
    end
  end

  context "when the API returns error" do
    before do
      stub_request(:get, api_url).to_return(status: 429, body: "Rate limit exceeded")
    end

    it "enqueues UpdatePriceJob with empty array" do
      expect { described_class.perform_now }.to have_enqueued_job(UpdatePriceJob).exactly(2).times

      expect(UpdatePriceJob).to have_been_enqueued.with(product1.id.to_s, nil)
      expect(UpdatePriceJob).to have_been_enqueued.with(product2.id.to_s, nil)
    end
  end
end
