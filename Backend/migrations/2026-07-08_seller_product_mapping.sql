-- Shared master product catalog + per-seller mapping.
-- Run this against production, then run the one-time backfill in this
-- session's notes (or re-derive: see linear-twirling-thompson.md plan).

ALTER TABLE `products`
  ADD COLUMN `status` ENUM('pending','approved') DEFAULT 'approved' AFTER `stock`,
  ADD COLUMN `submitted_by_seller_id` INT NULL AFTER `status`;

CREATE TABLE `seller_product_mapping` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `seller_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `saleprice` DECIMAL(10,2) NOT NULL,
  `stock` INT NOT NULL DEFAULT 0,
  `discount` DECIMAL(5,2) NULL,
  `sku` VARCHAR(50) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uniq_seller_product` (`seller_id`, `product_id`)
);

ALTER TABLE `order_items` ADD COLUMN `seller_id` INT NULL AFTER `variant_id`;

-- One-time backfill: preserve every existing non-variant seller listing as
-- its own mapping row, exactly as-is, with zero re-entry needed.
INSERT INTO seller_product_mapping (seller_id, product_id, price, saleprice, stock)
SELECT seller_id, id, rate, saleprice, stock
FROM products
WHERE hasvarients = 'no';

-- Backfill seller attribution on historical order lines.
UPDATE order_items oi
JOIN products p ON p.id = oi.product_id
SET oi.seller_id = p.seller_id
WHERE oi.seller_id IS NULL;

-- Existing rows are already live.
UPDATE products SET status = 'approved' WHERE status IS NULL;
