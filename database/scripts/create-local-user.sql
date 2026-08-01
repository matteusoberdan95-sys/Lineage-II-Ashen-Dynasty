-- This template is rendered only in memory by import-base-schema.ps1.
-- Never replace the token with a real password in this tracked file.

CREATE USER IF NOT EXISTS 'l2server'@'127.0.0.1'
  IDENTIFIED BY '__L2SERVER_PASSWORD__';

ALTER USER 'l2server'@'127.0.0.1'
  IDENTIFIED BY '__L2SERVER_PASSWORD__';

GRANT ALL PRIVILEGES ON `l2jmobiusinterlude`.*
  TO 'l2server'@'127.0.0.1';
