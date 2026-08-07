-- ================================================================
-- OneMind ENT and DIM databases
===================================================================
-- ----------------------------------------------------------------
-- 1. Create the Enterprise and Dimensional databases.
-- ----------------------------------------------------------------
USE ROLE SYSADMIN;

CREATE WAREHOUSE IF NOT EXISTS TRANSFORM_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'dbt transformation warehouse';

CREATE DATABASE IF NOT EXISTS ONEMIND_ENT_DW
    DATA_RETENTION_TIME_IN_DAYS = 7
    COMMENT = 'OneMind enterprise Data Vault and Business Vault';

CREATE SCHEMA IF NOT EXISTS ONEMIND_ENT_DW.STAGING
    COMMENT = 'Standardised dbt source models';

CREATE SCHEMA IF NOT EXISTS ONEMIND_ENT_DW.RAW_VAULT
    COMMENT = 'Data Vault hubs, links and source satellites';

CREATE SCHEMA IF NOT EXISTS ONEMIND_ENT_DW.BUSINESS_VAULT
    COMMENT = 'Matching, mastering and other business rules';

CREATE SCHEMA IF NOT EXISTS ONEMIND_ENT_DW.AUDIT
    COMMENT = 'Reconciliation and data-quality outputs';

CREATE DATABASE IF NOT EXISTS ONEMIND_DIM_DW
    DATA_RETENTION_TIME_IN_DAYS = 7
    COMMENT = 'OneMind Kimball dimensional warehouse';

CREATE SCHEMA IF NOT EXISTS ONEMIND_DIM_DW.CORE
    COMMENT = 'Conformed Kimball dimensions and facts';

CREATE SCHEMA IF NOT EXISTS ONEMIND_DIM_DW.MARTS
    COMMENT = 'Business reporting marts';

CREATE SCHEMA IF NOT EXISTS ONEMIND_DIM_DW.SEMANTIC
    COMMENT = 'Approved views consumed by Power BI';

-- --------------------------------------------------------------------------
-- 2. Create the dbt functional role if it does not already exist.
-- --------------------------------------------------------------------------
USE ROLE SECURITYADMIN;

CREATE ROLE IF NOT EXISTS DBT_ROLE
    COMMENT = 'dbt Cloud transformation role';

GRANT ROLE DBT_ROLE TO ROLE SYSADMIN;

GRANT USAGE, OPERATE ON WAREHOUSE TRANSFORM_WH
TO ROLE DBT_ROLE;

-- --------------------------------------------------------------------------
-- 3. Raw read-only access.
-- --------------------------------------------------------------------------
GRANT USAGE ON DATABASE ONEMIND_RAW_DB
TO ROLE DBT_ROLE;

GRANT USAGE ON SCHEMA ONEMIND_RAW_DB.public
TO ROLE DBT_ROLE;

GRANT SELECT ON ALL TABLES IN SCHEMA ONEMIND_RAW_DB.public
TO ROLE DBT_ROLE;

GRANT SELECT ON FUTURE TABLES IN SCHEMA ONEMIND_RAW_DB.public
TO ROLE DBT_ROLE;

-- --------------------------------------------------------------------------
-- 4. Build access to explicitly approved Enterprise DW schemas.
-- --------------------------------------------------------------------------
GRANT USAGE ON DATABASE ONEMIND_ENT_DW
TO ROLE DBT_ROLE;

GRANT USAGE ON SCHEMA ONEMIND_ENT_DW.STAGING
TO ROLE DBT_ROLE;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA ONEMIND_ENT_DW.STAGING
TO ROLE DBT_ROLE;

GRANT USAGE ON SCHEMA ONEMIND_ENT_DW.RAW_VAULT
TO ROLE DBT_ROLE;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA ONEMIND_ENT_DW.RAW_VAULT
TO ROLE DBT_ROLE;

GRANT USAGE ON SCHEMA ONEMIND_ENT_DW.BUSINESS_VAULT
TO ROLE DBT_ROLE;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA ONEMIND_ENT_DW.BUSINESS_VAULT
TO ROLE DBT_ROLE;

GRANT USAGE ON SCHEMA ONEMIND_ENT_DW.AUDIT
TO ROLE DBT_ROLE;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA ONEMIND_ENT_DW.AUDIT
TO ROLE DBT_ROLE;

-- dbt may need to replace or modify objects it created.
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
ON ALL TABLES IN DATABASE ONEMIND_ENT_DW
TO ROLE DBT_ROLE;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
ON FUTURE TABLES IN DATABASE ONEMIND_ENT_DW
TO ROLE DBT_ROLE;

GRANT SELECT ON ALL VIEWS IN DATABASE ONEMIND_ENT_DW
TO ROLE DBT_ROLE;

GRANT SELECT ON FUTURE VIEWS IN DATABASE ONEMIND_ENT_DW
TO ROLE DBT_ROLE;

-- --------------------------------------------------------------------------
-- 5. Build access to explicitly approved Dimensional DW schemas.
-- --------------------------------------------------------------------------
GRANT USAGE ON DATABASE ONEMIND_DIM_DW
TO ROLE DBT_ROLE;

GRANT USAGE ON SCHEMA ONEMIND_DIM_DW.CORE
TO ROLE DBT_ROLE;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA ONEMIND_DIM_DW.CORE
TO ROLE DBT_ROLE;

GRANT USAGE ON SCHEMA ONEMIND_DIM_DW.MARTS
TO ROLE DBT_ROLE;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA ONEMIND_DIM_DW.MARTS
TO ROLE DBT_ROLE;

GRANT USAGE ON SCHEMA ONEMIND_DIM_DW.SEMANTIC
TO ROLE DBT_ROLE;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA ONEMIND_DIM_DW.SEMANTIC
TO ROLE DBT_ROLE;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
ON ALL TABLES IN DATABASE ONEMIND_DIM_DW
TO ROLE DBT_ROLE;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
ON FUTURE TABLES IN DATABASE ONEMIND_DIM_DW
TO ROLE DBT_ROLE;

GRANT SELECT ON ALL VIEWS IN DATABASE ONEMIND_DIM_DW
TO ROLE DBT_ROLE;

GRANT SELECT ON FUTURE VIEWS IN DATABASE ONEMIND_DIM_DW
TO ROLE DBT_ROLE;

-- --------------------------------------------------------------------------
-- 6. Create the dbt service user and assign its role.
--    Authentication (normally an RSA public key) is configured separately
--    when creating the dbt Cloud Snowflake connection.
-- --------------------------------------------------------------------------
USE ROLE USERADMIN;

CREATE USER IF NOT EXISTS SVC_DBT
    TYPE = SERVICE
    DEFAULT_ROLE = DBT_ROLE
    DEFAULT_WAREHOUSE = TRANSFORM_WH
    DEFAULT_NAMESPACE = 'ONEMIND_ENT_DW.STAGING'
    COMMENT = 'dbt Cloud Snowflake service user';

USE ROLE SECURITYADMIN;

GRANT ROLE DBT_ROLE TO USER SVC_DBT;

-- --------------------------------------------------------------------------
-- 7. Validation.
-- --------------------------------------------------------------------------
SHOW DATABASES LIKE 'ONEMIND_%';
SHOW SCHEMAS IN DATABASE ONEMIND_ENT_DW;
SHOW SCHEMAS IN DATABASE ONEMIND_DIM_DW;
SHOW GRANTS TO ROLE DBT_ROLE;


-- use database onemind_ent_dw;
-- drop schema raw_vault;
-- drop schema business_vault;
-- drop schema staging;