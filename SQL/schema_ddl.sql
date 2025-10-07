-- Graves Greenery - Basic Star Schema DDL
-- Portable: adjust types as needed for your RDBMS

CREATE TABLE dim_customers (
  customer_id        INTEGER PRIMARY KEY,
  first_name         VARCHAR(50),
  last_name          VARCHAR(50),
  email              VARCHAR(120),
  phone              VARCHAR(30),
  address1           VARCHAR(120),
  address2           VARCHAR(120),
  city               VARCHAR(80),
  state_province     VARCHAR(40),
  postal_code        VARCHAR(20),
  country            VARCHAR(60),
  signup_ts          TIMESTAMP,
  marketing_opt_in   BOOLEAN,
  loyalty_tier       VARCHAR(20),
  source_channel     VARCHAR(30)
);

CREATE TABLE dim_categories (
  category_id        INTEGER PRIMARY KEY,
  category_level1    VARCHAR(30),
  category_level2    VARCHAR(40),
  genus              VARCHAR(60)
);

CREATE TABLE dim_plants (
  plant_id           INTEGER PRIMARY KEY,
  scientific_name    VARCHAR(120),
  common_name        VARCHAR(120),
  genus              VARCHAR(60),
  indoor_outdoor     VARCHAR(10),
  category_id_fk     INTEGER,
  pot_size           VARCHAR(10),
  sku                VARCHAR(40),
  is_pet_toxic       BOOLEAN,
  light_req          VARCHAR(30),
  water_req          VARCHAR(20),
  avg_maturity_height_in INTEGER,
  msrp               DECIMAL(10,2),
  cost_basis         DECIMAL(10,2),
  price_band         VARCHAR(20),
  rarity_score       INTEGER,
  FOREIGN KEY (category_id_fk) REFERENCES dim_categories(category_id)
);

CREATE TABLE dim_locations (
  location_id        INTEGER PRIMARY KEY,
  location_name      VARCHAR(80),
  address1           VARCHAR(120),
  city               VARCHAR(80),
  state_province     VARCHAR(40),
  postal_code        VARCHAR(20),
  country            VARCHAR(60)
);

CREATE TABLE dim_dates (
  date_key           INTEGER PRIMARY KEY,
  full_date          DATE,
  year               INTEGER,
  quarter            INTEGER,
  month              INTEGER,
  month_name         VARCHAR(15),
  day                INTEGER,
  day_of_week        INTEGER,
  day_name           VARCHAR(10),
  is_weekend         BOOLEAN
);

CREATE TABLE dim_inventory (
  inventory_id       INTEGER PRIMARY KEY,
  plant_id_fk        INTEGER,
  location_id_fk     INTEGER,
  on_hand_qty        INTEGER,
  reorder_point      INTEGER,
  safety_stock       INTEGER,
  last_count_ts      TIMESTAMP,
  last_receipt_ts    TIMESTAMP,
  FOREIGN KEY (plant_id_fk) REFERENCES dim_plants(plant_id),
  FOREIGN KEY (location_id_fk) REFERENCES dim_locations(location_id)
);

CREATE TABLE fact_orders (
  order_id               INTEGER PRIMARY KEY,
  order_ts               TIMESTAMP,
  order_date_key         INTEGER,
  customer_id_fk         INTEGER,
  order_channel          VARCHAR(20),
  store_location_id_fk   INTEGER,
  subtotal               DECIMAL(12,2),
  discount               DECIMAL(12,2),
  tax                    DECIMAL(12,2),
  shipping_fee           DECIMAL(12,2),
  grand_total            DECIMAL(12,2),
  payment_method         VARCHAR(20),
  order_status           VARCHAR(20),
  coupon_code            VARCHAR(30),
  FOREIGN KEY (order_date_key) REFERENCES dim_dates(date_key),
  FOREIGN KEY (customer_id_fk) REFERENCES dim_customers(customer_id),
  FOREIGN KEY (store_location_id_fk) REFERENCES dim_locations(location_id)
);

CREATE TABLE fact_order_items (
  order_item_id          INTEGER PRIMARY KEY,
  order_id_fk            INTEGER,
  plant_id_fk            INTEGER,
  unit_price             DECIMAL(12,2),
  unit_cost_snapshot     DECIMAL(12,2),
  qty                    INTEGER,
  line_discount          DECIMAL(12,2),
  fulfilled_qty          INTEGER,
  ship_from_location_id_fk INTEGER,
  FOREIGN KEY (order_id_fk) REFERENCES fact_orders(order_id),
  FOREIGN KEY (plant_id_fk) REFERENCES dim_plants(plant_id),
  FOREIGN KEY (ship_from_location_id_fk) REFERENCES dim_locations(location_id)
);

CREATE INDEX idx_orders_date       ON fact_orders(order_date_key);
CREATE INDEX idx_orders_customer   ON fact_orders(customer_id_fk);
CREATE INDEX idx_items_order       ON fact_order_items(order_id_fk);
CREATE INDEX idx_items_plant       ON fact_order_items(plant_id_fk);
CREATE UNIQUE INDEX ux_plants_sku  ON dim_plants(sku);
