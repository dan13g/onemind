-- ============================================================
-- OneMind RAW database for Fivetran
-- ============================================================

USE ROLE SYSADMIN;

CREATE DATABASE IF NOT EXISTS ONEMIND_RAW_DB
    COMMENT = 'Raw landing database for OneMind and BrightPath source systems';

CREATE SCHEMA IF NOT EXISTS ONEMIND_RAW_DB.ONEMIND
    COMMENT = 'Raw OneMind Supabase tables loaded by Fivetran';

CREATE SCHEMA IF NOT EXISTS ONEMIND_RAW_DB.BRIGHTPATH
    COMMENT = 'Raw BrightPath Supabase tables loaded by Fivetran';


-- ============================================================
-- Fivetran warehouse
-- ============================================================

CREATE WAREHOUSE IF NOT EXISTS LOAD_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse used by Fivetran';


-- ============================================================
-- Fivetran role
-- ============================================================

USE ROLE SECURITYADMIN;

CREATE ROLE IF NOT EXISTS FIVETRAN_ROLE
    COMMENT = 'Role used by Fivetran to load raw source data';

GRANT USAGE, OPERATE
ON WAREHOUSE LOAD_WH
TO ROLE FIVETRAN_ROLE;

GRANT USAGE
ON DATABASE ONEMIND_RAW_DB
TO ROLE FIVETRAN_ROLE;

GRANT USAGE
ON SCHEMA ONEMIND_RAW_DB.ONEMIND
TO ROLE FIVETRAN_ROLE;

GRANT USAGE
ON SCHEMA ONEMIND_RAW_DB.BRIGHTPATH
TO ROLE FIVETRAN_ROLE;

GRANT CREATE TABLE, CREATE VIEW, CREATE STAGE, CREATE FILE FORMAT
ON SCHEMA ONEMIND_RAW_DB.ONEMIND
TO ROLE FIVETRAN_ROLE;

GRANT CREATE TABLE, CREATE VIEW, CREATE STAGE, CREATE FILE FORMAT
ON SCHEMA ONEMIND_RAW_DB.BRIGHTPATH
TO ROLE FIVETRAN_ROLE;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
ON ALL TABLES IN SCHEMA ONEMIND_RAW_DB.ONEMIND
TO ROLE FIVETRAN_ROLE;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
ON ALL TABLES IN SCHEMA ONEMIND_RAW_DB.BRIGHTPATH
TO ROLE FIVETRAN_ROLE;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
ON FUTURE TABLES IN SCHEMA ONEMIND_RAW_DB.ONEMIND
TO ROLE FIVETRAN_ROLE;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE
ON FUTURE TABLES IN SCHEMA ONEMIND_RAW_DB.BRIGHTPATH
TO ROLE FIVETRAN_ROLE;


-- ============================================================
-- Optional Fivetran service user
-- ============================================================

USE ROLE USERADMIN;

CREATE USER IF NOT EXISTS SVC_FIVETRAN
    TYPE = SERVICE
    DEFAULT_ROLE = FIVETRAN_ROLE
    DEFAULT_WAREHOUSE = LOAD_WH
    DEFAULT_NAMESPACE = 'ONEMIND_RAW_DB.ONEMIND'
    COMMENT = 'Fivetran Snowflake destination user';

USE ROLE SECURITYADMIN;

GRANT ROLE FIVETRAN_ROLE
TO USER SVC_FIVETRAN;


-- ============================================================
-- Validation
-- ============================================================

SHOW DATABASES LIKE 'ONEMIND_RAW_DB';
SHOW SCHEMAS IN DATABASE ONEMIND_RAW_DB;
SHOW WAREHOUSES LIKE 'LOAD_WH';
SHOW ROLES LIKE 'FIVETRAN_ROLE';
SHOW USERS LIKE 'SVC_FIVETRAN';


--==============
--TEST Data Sync
--==============
select * from ONEMIND_RAW_DB."public"."onemind_clients";

select * from ONEMIND_RAW_DB."public"."brightpath_clients";

select *
from ONEMIND_RAW_DB."public"."onemind_clients"



