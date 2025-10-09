# Graves Greenery — Data Dictionary

Generated: 2025-10-09 19:45 UTC

## Star/Snowflake Overview


**Dimensions**  
- `dim_plant_category` — plant category lookup (1 row per category)  
- `dim_plants` — plant catalog (1 row per SKU/variant)  
- `dim_locations` — store/DC locations and channels  
- `dim_customers` — customer master (limited duplicate full names by design)  
- `dim_dates` — daily calendar (for time-series joins)  
- `dim_inventory` — snapshot of on-hand quantity by location × plant  
- `dim_promotions` — promotion metadata (codes, type, value, active window)  
- `dim_return_reason` — standardized reasons for returns  

**Facts**  
- `fact_orders` — one row per order (with `promotion_id` when a code was used)  
- `fact_order_items` — one row per order line (plant-level)  
- `fact_order_promotions` — bridge (order ↔ promotion), ready for multiple promos  
- `fact_returns` — one row per returned order line (partial or full qty)

**Convenience extract**  
- `graves_greenery_full_denormalized` — a single wide table joined across facts/dims for quick prototyping.


---

## dim_plant_category

| Column | Type | Description |
|---|---|---|

| `category_id` | INT PK | Surrogate key |

| `category_name` | TEXT | Category name (e.g., Tropicals) |

| `category_description` | TEXT | Short description of category |


---

## dim_plants

| Column | Type | Description |
|---|---|---|

| `plant_id` | INT PK | Surrogate key |

| `sku` | TEXT | SKU-like slug (snake_case) |

| `plant_name` | TEXT | Botanical name + cultivar + size (e.g., *Monstera deliciosa* 'Variegata' 6in) |

| `category_id` | INT FK | FK to `dim_plant_category.category_id` |

| `unit_cost` | NUMERIC | Estimated cost to store |

| `list_price` | NUMERIC | List/retail price (pre-discount) |


---

## dim_locations

| Column | Type | Description |
|---|---|---|

| `location_id` | INT PK | Surrogate key |

| `location_name` | TEXT | Location name (e.g., Camas Store) |

| `city` | TEXT | City |

| `state_province` | TEXT | State/Province |

| `country` | TEXT | Country |

| `channel` | TEXT | Primary channel for this location (In-Store / Online) |


---

## dim_customers

| Column | Type | Description |
|---|---|---|

| `customer_id` | INT PK | Surrogate key |

| `first_name` | TEXT | First name |

| `last_name` | TEXT | Last name |

| `email` | TEXT | Unique-ish email (few internal @gravesgreenery.com) |

| `phone` | TEXT | Phone number |

| `address1` | TEXT | Street address |

| `address2` | TEXT | Suite/Apt (often empty) |

| `city` | TEXT | City |

| `state_province` | TEXT | State/Province |

| `postal_code` | TEXT | ZIP/Postal |

| `country` | TEXT | USA/Canada |

| `signup_ts` | TIMESTAMP | Customer signup timestamp |

| `marketing_opt_in` | TEXT | 'TRUE' or 'FALSE' |

| `loyalty_tier` | TEXT | Green / Silver / Gold / Emerald |

| `source_channel` | TEXT | Acquisition source (Website/In-Store/Instagram/Referral/Ad Campaign) |


---

## dim_dates

| Column | Type | Description |
|---|---|---|

| `date_id` | INT PK | Unix seconds (surrogate) |

| `date` | DATE | YYYY-MM-DD |

| `year` | INT | Year |

| `quarter` | INT | 1–4 |

| `month` | INT | 1–12 |

| `day` | INT | 1–31 |

| `day_name` | TEXT | Monday–Sunday |

| `is_weekend` | BOOLEAN | Weekend flag |


---

## dim_inventory

| Column | Type | Description |
|---|---|---|

| `location_id` | INT FK | FK to `dim_locations.location_id` |

| `plant_id` | INT FK | FK to `dim_plants.plant_id` |

| `on_hand_qty` | INT | Estimated on-hand at generation time |


---

## dim_promotions

| Column | Type | Description |
|---|---|---|

| `promotion_id` | INT PK | Surrogate key |

| `promo_code` | TEXT | Code used on orders |

| `description` | TEXT | Promo description |

| `discount_type` | TEXT | PCT / FIXED / BOGO50 |

| `discount_value` | NUMERIC | % or $ depending on type |

| `start_date` | DATE | Promo start (YYYY-MM-DD) |

| `end_date` | DATE | Promo end (YYYY-MM-DD) |

| `channel_scope` | TEXT | All / Online / In-Store |

| `is_stackable` | BOOLEAN | Whether promo can stack with others |


---

## dim_return_reason

| Column | Type | Description |
|---|---|---|

| `return_reason_id` | INT PK | Surrogate key |

| `reason` | TEXT | Reason text (e.g., Damaged on Arrival) |


---

## fact_orders

| Column | Type | Description |
|---|---|---|

| `order_id` | INT PK | Order identifier |

| `customer_id` | INT FK | FK to `dim_customers.customer_id` |

| `location_id` | INT FK | FK to `dim_locations.location_id` |

| `order_ts` | TIMESTAMP | Order timestamp |

| `sales_channel` | TEXT | Online / Camas Store / Vancouver Store |

| `coupon_code` | TEXT | Raw coupon code (if present) |

| `promotion_id` | INT FK (nullable) | FK to `dim_promotions.promotion_id` |

| `fulfillment_method` | TEXT | Standard / Express / Pickup / Carryout |


---

## fact_order_items

| Column | Type | Description |
|---|---|---|

| `order_item_id` | INT PK | Line identifier |

| `order_id` | INT FK | FK to `fact_orders.order_id` |

| `plant_id` | INT FK | FK to `dim_plants.plant_id` |

| `quantity` | INT | Units purchased |

| `unit_price` | NUMERIC | Transaction unit price |

| `line_subtotal` | NUMERIC | unit_price × quantity before discounts |

| `discount_amount` | NUMERIC | Discount on this line based on coupon |

| `tax_amount` | NUMERIC | Sales tax on net |

| `shipping_amount` | NUMERIC | Shipping cost allocated to line |

| `estimated_margin` | NUMERIC | Net – (unit_cost × quantity) |


---

## fact_order_promotions

| Column | Type | Description |
|---|---|---|

| `order_id` | INT FK | FK to `fact_orders.order_id` |

| `promotion_id` | INT FK | FK to `dim_promotions.promotion_id` |


---

## fact_returns

| Column | Type | Description |
|---|---|---|

| `return_id` | INT PK | Return identifier |

| `order_item_id` | INT FK | FK to `fact_order_items.order_item_id` |

| `order_id` | INT FK | FK to `fact_orders.order_id` |

| `customer_id` | INT FK | FK to `dim_customers.customer_id` |

| `plant_id` | INT FK | FK to `dim_plants.plant_id` |

| `return_reason_id` | INT FK | FK to `dim_return_reason.return_reason_id` |

| `return_ts` | TIMESTAMP | Return timestamp |

| `quantity_returned` | INT | Returned units (≤ original qty) |

| `refund_amount` | NUMERIC | Refund issued for the return |

| `restocking_fee` | NUMERIC | Fee retained (if applicable) |

| `promotion_id` | INT FK (nullable) | FK to `dim_promotions.promotion_id` (if order used a promo) |


---

## graves_greenery_full_denormalized

| Column | Type | Description |
|---|---|---|

| `order_item_id` | INT | Order line id |

| `order_id` | INT | Order id |

| `order_ts` | TIMESTAMP | Order timestamp |

| `sales_channel` | TEXT | Channel of sale |

| `coupon_code` | TEXT | Raw coupon |

| `fulfillment_method` | TEXT | Fulfillment method |

| `location_id` | INT | Location id |

| `location_name` | TEXT | Location name |

| `location_city` | TEXT | Location city |

| `location_state` | TEXT | Location state/province |

| `location_country` | TEXT | Location country |

| `customer_id` | INT | Customer id |

| `first_name` | TEXT | First name |

| `last_name` | TEXT | Last name |

| `email` | TEXT | Email address |

| `phone` | TEXT | Phone number |

| `customer_city` | TEXT | Customer city |

| `customer_state` | TEXT | Customer state/province |

| `postal_code` | TEXT | Postal/ZIP |

| `customer_country` | TEXT | Country |

| `loyalty_tier` | TEXT | Loyalty tier |

| `source_channel` | TEXT | Acquisition source |

| `plant_id` | INT | Plant id |

| `sku` | TEXT | SKU |

| `plant_name` | TEXT | Plant variant name |

| `category_id` | INT | Plant category id |

| `category_name` | TEXT | Plant category name |

| `quantity` | INT | Qty purchased |

| `unit_price` | NUMERIC | Transaction unit price |

| `line_subtotal` | NUMERIC | Subtotal before discount |

| `discount_amount` | NUMERIC | Discount on line |

| `tax_amount` | NUMERIC | Sales tax |

| `shipping_amount` | NUMERIC | Shipping allocated |

| `estimated_margin` | NUMERIC | Estimated line margin |
