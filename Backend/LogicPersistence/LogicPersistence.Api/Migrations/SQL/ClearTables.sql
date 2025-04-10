BEGIN;

SET CONSTRAINTS ALL DEFERRED;
TRUNCATE TABLE place_affected_zone CASCADE;
TRUNCATE TABLE affected_zone_location CASCADE;
TRUNCATE TABLE need_need_type CASCADE;
TRUNCATE TABLE need_skill CASCADE;
TRUNCATE TABLE need_task CASCADE;
TRUNCATE TABLE route_location CASCADE;
TRUNCATE TABLE task_donation CASCADE;
TRUNCATE TABLE task_skill CASCADE;
TRUNCATE TABLE volunteer_place CASCADE;
TRUNCATE TABLE volunteer_task CASCADE;
TRUNCATE TABLE volunteer_skill CASCADE;
TRUNCATE TABLE volunteer_time CASCADE;
TRUNCATE TABLE task_time CASCADE;
TRUNCATE TABLE route CASCADE;
TRUNCATE TABLE need_type CASCADE;
TRUNCATE TABLE need CASCADE;
TRUNCATE TABLE task CASCADE;
TRUNCATE TABLE skill CASCADE;
TRUNCATE TABLE place CASCADE;
TRUNCATE TABLE monetary_donation CASCADE;
TRUNCATE TABLE physical_donation CASCADE;
TRUNCATE TABLE affected_zone CASCADE;
TRUNCATE TABLE admin CASCADE;
TRUNCATE TABLE volunteer CASCADE;
TRUNCATE TABLE victim CASCADE;
TRUNCATE TABLE location CASCADE;

-- Reset all sequences for tables with SERIAL columns
SELECT setval(pg_get_serial_sequence('location', 'id'), 1, false);
SELECT setval(pg_get_serial_sequence('victim', 'id'), 1, false);
SELECT setval(pg_get_serial_sequence('volunteer', 'id'), 1, false);
SELECT setval(pg_get_serial_sequence('admin', 'id'), 1, false);
SELECT setval(pg_get_serial_sequence('affected_zone', 'id'), 1, false);
SELECT setval(pg_get_serial_sequence('physical_donation', 'id'), 1, false);
SELECT setval(pg_get_serial_sequence('monetary_donation', 'id'), 1, false);
SELECT setval(pg_get_serial_sequence('place', 'id'), 1, false);
SELECT setval(pg_get_serial_sequence('skill', 'id'), 1, false);
SELECT setval(pg_get_serial_sequence('task', 'id'), 1, false);
SELECT setval(pg_get_serial_sequence('need', 'id'), 1, false);
SELECT setval(pg_get_serial_sequence('need_type', 'id'), 1, false);
SELECT setval(pg_get_serial_sequence('route', 'id'), 1, false);
SELECT setval(pg_get_serial_sequence('task_time', 'id'), 1, false);
SELECT setval(pg_get_serial_sequence('volunteer_time', 'id'), 1, false);

SET CONSTRAINTS ALL IMMEDIATE;

COMMIT;