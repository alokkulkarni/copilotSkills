# DynamoDB Table Module - Example Data

Sample JSON data files for populating DynamoDB tables during testing and development.

## Data Files

### sample-users.json
Sample user records with the following schema:
- `userId` (S): Unique user identifier
- `name` (S): User's full name
- `email` (S): User's email address
- `role` (S): User role (admin, user, moderator)
- `createdAt` (N): Unix timestamp of account creation
- `lastLogin` (N): Unix timestamp of last login
- `active` (BOOL): Account status

### sample-products.json
Sample product catalog with the following schema:
- `productId` (S): Unique product identifier
- `name` (S): Product name
- `category` (S): Product category
- `price` (N): Product price in USD
- `stock` (N): Available quantity
- `createdAt` (N): Unix timestamp of product creation

### sample-orders.json
Sample order records with the following schema:
- `orderId` (S): Unique order identifier
- `userId` (S): Reference to user
- `productId` (S): Reference to product
- `quantity` (N): Order quantity
- `totalAmount` (N): Total order amount
- `status` (S): Order status (pending, shipped, completed)
- `orderDate` (N): Unix timestamp of order
- `shippingAddress` (S): Delivery address

## Usage

### Using the populate-data script

```bash
# Populate users table
../scripts/populate-data.sh users-table data/sample-users.json

# Populate products table
../scripts/populate-data.sh products-table data/sample-products.json

# Populate orders table
../scripts/populate-data.sh orders-table data/sample-orders.json
```

### Using AWS CLI directly

```bash
# Single item
aws dynamodb put-item \
  --table-name users-table \
  --item file://data/sample-users.json

# Batch write (requires request-items format)
aws dynamodb batch-write-item \
  --request-items file://batch-request.json
```

## Data Format

All data files use DynamoDB JSON format with type descriptors:
- `S`: String
- `N`: Number (stored as string)
- `BOOL`: Boolean
- `M`: Map (nested object)
- `L`: List (array)
- `SS`: String Set
- `NS`: Number Set
- `BS`: Binary Set
- `NULL`: Null

## Generating Custom Data

You can create your own data files following the same format. Example template:

```json
[
  {
    "primaryKey": {"S": "value"},
    "sortKey": {"N": "123"},
    "attribute1": {"S": "string value"},
    "attribute2": {"N": "42"},
    "attribute3": {"BOOL": true},
    "nestedObject": {
      "M": {
        "key1": {"S": "value1"},
        "key2": {"N": "100"}
      }
    },
    "listAttribute": {
      "L": [
        {"S": "item1"},
        {"S": "item2"}
      ]
    }
  }
]
```

## Notes

- These are sample datasets for development and testing only
- Do not use in production without proper validation
- Timestamps are in Unix epoch format (seconds since 1970-01-01)
- Ensure your table schema matches the data structure before loading
- The populate-data script automatically handles batching for large datasets
