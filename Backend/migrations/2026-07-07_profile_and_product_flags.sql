-- Run this against the production database to apply the schema changes
-- that ship with this update (profile username/gender fields, and the
-- Best Seller / Recommended product flags).

ALTER TABLE `users`
  ADD COLUMN `username` varchar(50) DEFAULT NULL AFTER `name`,
  ADD COLUMN `gender` enum('male','female','other') DEFAULT NULL AFTER `username`;

ALTER TABLE `products`
  ADD COLUMN `bestseller` enum('yes','no') DEFAULT 'no' AFTER `topdeals`,
  ADD COLUMN `recommended` enum('yes','no') DEFAULT 'no' AFTER `bestseller`;
