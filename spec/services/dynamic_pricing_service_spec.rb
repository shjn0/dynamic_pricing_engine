require 'rails_helper'

RSpec.describe DynamicPricingService do
  let(:product) do
    create(:product, name: "Nice Shoes", default_price: BigDecimal(100), dynamic_price: BigDecimal(100), qty: 100)
  end
  let(:competitor_product) do
    { "name" => "Nice Shoes", "category" => "Footwear", "price" => 120.0, "qty" => 200 }
  end

  before do
    stub_const(
      'ENV',
      ENV.to_hash.merge(
        {
          "PURCHASE_SEARCH_PERIOD"=>"day",
          "RATE_CHANGE_COMPETITOR"=>"95",
          "RATE_CHANGE_FREQUENT_PURCHASE"=>"10",
          "RATE_CHANGE_HIGH_QTY"=>"10",
          "RATE_CHANGE_LOW_QTY"=>"10",
          "THRESHOLD_FREQUENT_PURCHASE"=>"20",
          "THRESHOLD_HIGH_QTY"=>"200",
          "THRESHOLD_LOW_QTY"=>"10"
        }
      )
    )
  end

  context "when frequent purchased" do
    before do
      create(
        :order,
        order_items_attributes: [
          {
            product_id: product.id, qty: ENV['THRESHOLD_FREQUENT_PURCHASE'].to_i, price_per_item: product.dynamic_price
          }
        ]
      )
    end

    context "when inventory is low" do
      before { product.update(qty: ENV['THRESHOLD_LOW_QTY'].to_i - 1) }

      context "when there is no competitor product" do
        it "changes dynamic price" do
          expect {
            DynamicPricingService.new(product.id.to_s, nil).call
          }.to change { product.reload.dynamic_price }.from(BigDecimal(100)).to(BigDecimal(120))
        end
      end

      context "when competitor price is not lower" do
        it "changes dynamic price" do
          expect {
            DynamicPricingService.new(product.id.to_s, competitor_product).call
          }.to change { product.reload.dynamic_price }.from(BigDecimal(100)).to(BigDecimal(120))
        end
      end

      context "when competitor price is lower" do
        before { competitor_product["price"] = 119.0 }

        it "changes dynamic price" do
          expect {
            DynamicPricingService.new(product.id.to_s, competitor_product).call
          }.to change { product.reload.dynamic_price }.from(BigDecimal(100)).to(BigDecimal(113.05))
        end
      end
    end

    context "when inventory is normal" do
      context "when there is no competitor product" do
        it "changes dynamic price" do
          expect {
            DynamicPricingService.new(product.id.to_s, nil).call
          }.to change { product.reload.dynamic_price }.from(BigDecimal(100)).to(BigDecimal(110))
        end
      end

      context "when competitor price is not lower" do
        it "changes dynamic price" do
          expect {
            DynamicPricingService.new(product.id.to_s, competitor_product).call
          }.to change { product.reload.dynamic_price }.from(BigDecimal(100)).to(BigDecimal(110))
        end
      end

      context "when competitor price is lower" do
        before { competitor_product["price"] = 109.0 }

        it "changes dynamic price" do
          expect {
            DynamicPricingService.new(product.id.to_s, competitor_product).call
          }.to change { product.reload.dynamic_price }.from(BigDecimal(100)).to(BigDecimal(103.55))
        end
      end
    end

    context "when inventory is high" do
      before { product.update(qty: ENV['THRESHOLD_HIGH_QTY'].to_i) }

      context "when there is no competitor product" do
        it "does not change dynamic price" do
          expect {
            DynamicPricingService.new(product.id.to_s, nil).call
          }.not_to change { product.reload.dynamic_price }
        end
      end

      context "when competitor price is not lower" do
        it "does not change dynamic price" do
          expect {
            DynamicPricingService.new(product.id.to_s, competitor_product).call
          }.not_to change { product.reload.dynamic_price }
        end
      end

      context "when competitor price is lower" do
        before { competitor_product["price"] = 89.0 }

        it "changes dynamic price" do
          expect {
            DynamicPricingService.new(product.id.to_s, competitor_product).call
          }.to change { product.reload.dynamic_price }.from(BigDecimal(100)).to(BigDecimal(84.55))
        end
      end
    end
  end

  context "when not frequent purchased" do
    context "when inventory is low" do
      before { product.update(qty: ENV['THRESHOLD_LOW_QTY'].to_i - 1) }

      context "when there is no competitor product" do
        it "changes dynamic price" do
          expect {
            DynamicPricingService.new(product.id.to_s, nil).call
          }.to change { product.reload.dynamic_price }.from(BigDecimal(100)).to(BigDecimal(110))
        end
      end

      context "when competitor price is not lower" do
        it "changes dynamic price" do
          expect {
            DynamicPricingService.new(product.id.to_s, competitor_product).call
          }.to change { product.reload.dynamic_price }.from(BigDecimal(100)).to(BigDecimal(110))
        end
      end

      context "when competitor price is lower" do
        before { competitor_product["price"] = 109.0 }

        it "changes dynamic price" do
          expect {
            DynamicPricingService.new(product.id.to_s, competitor_product).call
          }.to change { product.reload.dynamic_price }.from(BigDecimal(100)).to(BigDecimal(103.55))
        end
      end
    end

    context "when inventory is normal" do
      context "when there is no competitor product" do
        it "does not change dynamic price" do
          expect {
            DynamicPricingService.new(product.id.to_s, nil).call
          }.not_to change { product.reload.dynamic_price }
        end
      end

      context "when competitor price is not lower" do
        it "does not change dynamic price" do
          expect {
            DynamicPricingService.new(product.id.to_s, competitor_product).call
          }.not_to change { product.reload.dynamic_price }
        end
      end

      context "when competitor price is lower" do
        before { competitor_product["price"] = 99.0 }

        it "changes dynamic price" do
          expect {
            DynamicPricingService.new(product.id.to_s, competitor_product).call
          }.to change { product.reload.dynamic_price }.from(BigDecimal(100)).to(BigDecimal(94.05))
        end
      end
    end

    context "when inventory is high" do
      before { product.update(qty: ENV['THRESHOLD_HIGH_QTY'].to_i) }

      context "when there is no competitor product" do
        it "changes dynamic price" do
          expect {
            DynamicPricingService.new(product.id.to_s, nil).call
          }.to change { product.reload.dynamic_price }.from(BigDecimal(100)).to(BigDecimal(90))
        end
      end

      context "when competitor price is not lower" do
        it "changes dynamic price" do
          expect {
            DynamicPricingService.new(product.id.to_s, competitor_product).call
          }.to change { product.reload.dynamic_price }.from(BigDecimal(100)).to(BigDecimal(90))
        end
      end

      context "when competitor price is lower" do
        before { competitor_product["price"] = 89.0 }

        it "changes dynamic price" do
          expect {
            DynamicPricingService.new(product.id.to_s, competitor_product).call
          }.to change { product.reload.dynamic_price }.from(BigDecimal(100)).to(BigDecimal(84.55))
        end
      end
    end
  end
end
