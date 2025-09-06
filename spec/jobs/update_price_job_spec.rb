require 'rails_helper'

RSpec.describe UpdatePriceJob, type: :job do
  let(:product_id) { create(:product).id.to_s }
  let(:competitor_product) do
    { "name" => "MC Hammer Pants", "category" => "Footwear", "price" => 3005.0, "qty" => 285 }
  end

  it "calls DynamicPricingService with the args" do
    service = instance_double(DynamicPricingService, call: true)

    expect(DynamicPricingService)
      .to receive(:new)
      .with(product_id, competitor_product)
      .and_return(service)

    expect(service).to receive(:call)

    UpdatePriceJob.perform_now(product_id, competitor_product)
  end
end
