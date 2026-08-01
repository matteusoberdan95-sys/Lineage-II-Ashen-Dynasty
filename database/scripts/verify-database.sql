SELECT VERSION() AS mariadb_version;
SELECT CURRENT_USER() AS authenticated_account;
SELECT DATABASE() AS selected_database;

SELECT
  DEFAULT_CHARACTER_SET_NAME AS default_character_set,
  DEFAULT_COLLATION_NAME AS default_collation
FROM information_schema.SCHEMATA
WHERE SCHEMA_NAME = 'l2jmobiusinterlude';

SELECT COUNT(*) AS table_count
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'l2jmobiusinterlude'
  AND TABLE_TYPE = 'BASE TABLE';

SELECT COUNT(*) AS login_table_count
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'l2jmobiusinterlude'
  AND TABLE_NAME IN ('account_data', 'accounts', 'accounts_ipauth', 'gameservers');

SHOW GRANTS FOR CURRENT_USER;
