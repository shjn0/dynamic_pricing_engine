# README

## Overview of the E-commerce platform
### Basic CRUD
- Can view a paginated list of products or a single product.
- Can place orders by providing product IDs and desired quantities.
  - A successful order reduces inventory.
  - Orders fail if inventory is insufficient.
- Can view a paginated list of orders or a single order. Each order shows the total price per item and the total price of the order.

### Background process
- A cron job runs every 5 minutes to fetch competitor prices. These prices, along with product IDs, are used to enqueue jobs for updating product prices through the `DynamicPricingService`.

### DynamicPricingService's logic
- Accepts a product and the corresponding competitor product.
- Uses a default price-change percentage (100% means no change).
- Adjusts the percentage based on:
  - Purchase volume:
    - Sales are measured within a configurable time period (month, day, hour, or minute, set via ENV).
    - If sales exceed a configurable threshold, increase the percentage by a set amount (both defined via ENV).
  - Inventory levels:
    - If stock is below or above certain thresholds (via ENV), adjust the percentage up or down.
    - The adjustment value itself is also configurable via ENV.
- Calculates a new price and compares it with the competitor’s price:
  - If the new price is lower, keep it as is.
  - If it’s higher, cap it at a configurable percentage of the competitor’s price.
- Updates the product with the new price.

## Setup and run the application
- Install Docker and Docker Compose.
- Clone this repository.
- Create a `.env` file using the contents of `example.env`.
- Run the following command in the repository folder. The Rails app will be available at `http://localhost:3000/`, and the products will be imported automatically.
```
docker compose up --build -d
```

## API endpoints
### GET /products
- Returns a paginated list of all products, with 25 products per page.
```
curl --location 'http://localhost:3000/products'

# With page params:
curl --location 'http://localhost:3000/products?page=2'
```

- Response:
```
{
    "data": [
        {
            "id": "68c017c153cc4d72a75be62d",
            "type": "product",
            "attributes": {
                "name": "New Kids on the Block Tee",
                "category": "Clothing",
                "default_price": "3085.0",
                "dynamic_price": "3085.0",
                "qty": 34
            }
        },
        {
            "id": "68c017c153cc4d72a75be62e",
            "type": "product",
            "attributes": {
                "name": "Smurfs Cap",
                "category": "Accessories",
                "default_price": "7569.0",
                "dynamic_price": "7569.0",
                "qty": 54
            }
        },
        ...
}
```

### GET /products/{:product_id}
- Retrieves a single product.
```
curl --location 'http://localhost:3000/products/68c017c153cc4d72a75be62d'
```

- Response:
```
{
    "data": {
        "id": "68c017c153cc4d72a75be62d",
        "type": "product",
        "attributes": {
            "name": "New Kids on the Block Tee",
            "category": "Clothing",
            "default_price": "3085.0",
            "dynamic_price": "2755.0",
            "qty": 34
        }
    }
}
```

### POST /orders
- Place an order.
```
curl --location 'http://localhost:3000/orders' \
--header 'Content-Type: application/json' \
--data '{
    "order": {
        "order_items_attributes": [
            {
                "product_id": "68c017c053cc4d72a75be614",
                "qty": 1
            },
            {
                "product_id": "68c017c053cc4d72a75be615",
                "qty": 2
            }
        ]
    }
}'
```

- Success response:
```
{
    "data": {
        "id": "68c042db5b6ccb61f9fece8a",
        "type": "order",
        "attributes": {
            "order_items": {
                "data": [
                    {
                        "id": "68c042db5b6ccb61f9fece89",
                        "type": "order_item",
                        "attributes": {
                            "product_id": "68c017c053cc4d72a75be614",
                            "qty": 1,
                            "price_per_item": "2704.5",
                            "total_price": "2704.5"
                        }
                    },
                    {
                        "id": "68c042db5b6ccb61f9fece8b",
                        "type": "order_item",
                        "attributes": {
                            "product_id": "68c017c053cc4d72a75be615",
                            "qty": 2,
                            "price_per_item": "1359.9",
                            "total_price": "2719.8"
                        }
                    }
                ]
            },
            "total_price": "5424.3"
        }
    }
}
```

- When product is out of stock:
```
curl --location 'http://localhost:3000/orders' \
--header 'Content-Type: application/json' \
--data '{
    "order": {
        "order_items_attributes": [
            {
                "product_id": "68c017c053cc4d72a75be614",
                "qty": 1
            },
            {
                "product_id": "68c017c053cc4d72a75be615",
                "qty": 236
            }
        ]
    }
}'

# Response:
{
    "errors": [
        {
            "order_items": [
                "68c017c053cc4d72a75be615 is out of stock."
            ]
        }
    ]
}
```

### GET /orders
- Returns a paginated list of all orders, with 25 orders per page.
```
curl --location 'http://localhost:3000/orders'

# With page params:
curl --location 'http://localhost:3000/orders?page=2'
```

- Response:
```
{
    "data": [
        {
            "id": "68c042ad5b6ccb61f9fece87",
            "type": "order",
            "attributes": {
                "order_items": {
                    "data": [
                        {
                            "id": "68c042ad5b6ccb61f9fece86",
                            "type": "order_item",
                            "attributes": {
                                "product_id": "68c017c053cc4d72a75be614",
                                "qty": 1,
                                "price_per_item": "2704.5",
                                "total_price": "2704.5"
                            }
                        },
                        {
                            "id": "68c042ad5b6ccb61f9fece88",
                            "type": "order_item",
                            "attributes": {
                                "product_id": "68c017c053cc4d72a75be615",
                                "qty": 1,
                                "price_per_item": "1359.9",
                                "total_price": "1359.9"
                            }
                        }
                    ]
                },
                "total_price": "4064.4"
            }
        },
        {
            "id": "68c042db5b6ccb61f9fece8a",
            "type": "order",
            "attributes": {
                "order_items": {
                    "data": [
                        {
                            "id": "68c042db5b6ccb61f9fece89",
                            "type": "order_item",
                            "attributes": {
                                "product_id": "68c017c053cc4d72a75be614",
                                "qty": 1,
                                "price_per_item": "2704.5",
                                "total_price": "2704.5"
                            }
                        },
                        {
                            "id": "68c042db5b6ccb61f9fece8b",
                            "type": "order_item",
                            "attributes": {
                                "product_id": "68c017c053cc4d72a75be615",
                                "qty": 2,
                                "price_per_item": "1359.9",
                                "total_price": "2719.8"
                            }
                        }
                    ]
                },
                "total_price": "5424.3"
            }
        },
        ...
```

### GET /orders/{:order_id}
- Retrieves an order.
```
curl --location 'http://localhost:3000/orders/68c042ad5b6ccb61f9fece87'
```

- Response:
```
{
    "data": {
        "id": "68c042ad5b6ccb61f9fece87",
        "type": "order",
        "attributes": {
            "order_items": {
                "data": [
                    {
                        "id": "68c042ad5b6ccb61f9fece86",
                        "type": "order_item",
                        "attributes": {
                            "product_id": "68c017c053cc4d72a75be614",
                            "qty": 1,
                            "price_per_item": "2704.5",
                            "total_price": "2704.5"
                        }
                    },
                    {
                        "id": "68c042ad5b6ccb61f9fece88",
                        "type": "order_item",
                        "attributes": {
                            "product_id": "68c017c053cc4d72a75be615",
                            "qty": 1,
                            "price_per_item": "1359.9",
                            "total_price": "1359.9"
                        }
                    }
                ]
            },
            "total_price": "4064.4"
        }
    }
}
```
