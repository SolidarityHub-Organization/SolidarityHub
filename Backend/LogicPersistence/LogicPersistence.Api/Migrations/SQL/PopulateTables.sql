INSERT INTO "location" ("latitude", "longitude") VALUES
  (40.7128, -74.0060),
  (34.0522, -118.2437),
  (41.8781, -87.6298),
  (29.7604, -95.3698),
  (33.4484, -112.0740),
  (39.9526, -75.1652),
  (32.7157, -117.1611),
  (37.7749, -122.4194),
  (30.2672, -97.7431),
  (39.7392, -104.9903),
  (47.6062, -122.3321),
  (25.7617, -80.1918),
  (42.3601, -71.0589),
  (36.1699, -115.1398),
  (35.2271, -80.8431);

INSERT INTO "admin" ("name", "surname", "email", "password", "prefix", "phone_number", "address", "identification", "jurisdiction") VALUES
  ('John', 'Smith', 'admin1@solidarityhub.org', '$2a$12$tzXOz0COG7QQnANfJK3peuSsC1Eu2UvE/jBZLWrZkT7XhY6GD7Cji', 1, 5551234567, '123 Admin St, New York, NY 10001', 'ADM-001-2025', 'New York State'),
  ('Maria', 'Garcia', 'admin2@solidarityhub.org', '$2a$12$MDiUeuDPHxOQ1szQ1bdYoOQuV9AfBnY99CwgZA7brFoJMdT.JiWXO', 1, 5552345678, '456 Admin Ave, Los Angeles, CA 90001', 'ADM-002-2025', 'California'),
  ('David', 'Johnson', 'admin3@solidarityhub.org', '$2a$12$8kP5X1y/rH6LYOQnRtNY3uXjOBDw9T4k0tC0TtndTqgf7hOESOUWa', 1, 5553456789, '789 Admin Blvd, Chicago, IL 60601', 'ADM-003-2025', 'Illinois');

INSERT INTO "victim" ("name", "surname", "email", "password", "prefix", "phone_number", "address", "identification", "location_id") VALUES
  ('Alice', 'Wilson', 'alice@example.com', '$2a$12$gK6ByD5rYpjKXKPwjQF0y.ZTqJawPmPE/tvyWG9Jd02mHynm7RhLG', 1, 5551112222, '101 Victim St, New York, NY 10001', 'VCT-001-2025', 1),
  ('Bob', 'Martinez', 'bob@example.com', '$2a$12$1Wmcp3eV9hMMKCC14banc.GQ3.qW8wroD582CGnuVrA.tgm0W8REK', 1, 5552223333, '202 Victim Ave, Los Angeles, CA 90001', 'VCT-002-2025', 2),
  ('Carol', 'Taylor', 'carol@example.com', '$2a$12$0VT37J97D356KoQ8ZS2NAen4x5NAKWaYkNBYl/LGBSB7AeNnuY4XG', 1, 5553334444, '303 Victim Blvd, Chicago, IL 60601', 'VCT-003-2025', 3),
  ('Devin', 'Brown', 'devin@example.com', '$2a$12$eOKsPJL6PYJ/U1F9MFjgIuhiDybZXBZRrRsPaeIplk0Y9Xf.d2IXK', 1, 5554445555, '404 Victim Dr, Houston, TX 77001', 'VCT-004-2025', 4),
  ('Eva', 'Davis', 'eva@example.com', '$2a$12$KmS5FBVMmQXwDB20zcCwGO8c7o.Omht5LdK6QerZ8IFaGGlJxqCCO', 1, 5555556666, '505 Victim Ln, Phoenix, AZ 85001', 'VCT-005-2025', 5);

INSERT INTO "volunteer" ("name", "surname", "email", "password", "prefix", "phone_number", "address", "identification", "location_id") VALUES
  ('Frank', 'Lee', 'frank@example.com', '$2a$12$1V.4auSYXgNH2xAqE93aS.LuDHpti6ldZZThDSM0VvrogryE8W0Ui', 1, 5556667777, '101 Volunteer St, Philadelphia, PA 19101', 'VOL-001-2025', 6),
  ('Grace', 'Kim', 'grace@example.com', '$2a$12$iDfI0RWwfUEwEc7MDYZpsOD6vFylnT1gSkl3rF8IC.mtQMQKytrXG', 1, 5557778888, '202 Volunteer Ave, San Diego, CA 92101', 'VOL-002-2025', 7),
  ('Henry', 'Chen', 'henry@example.com', '$2a$12$T3OQ8bab.LX/YzJYYFW5N.ww8GfrFYdpLrHhD45ZJKg5D0rAgZlS2', 1, 5558889999, '303 Volunteer Blvd, San Francisco, CA 94101', 'VOL-003-2025', 8),
  ('Isabel', 'Lopez', 'isabel@example.com', '$2a$12$Hb3xZZWmPDyz6mTkD1qF9.K3ayAr0bd97UQJMc2lUvqQs8Idz3XYi', 1, 5559990000, '404 Volunteer Dr, Austin, TX 78701', 'VOL-004-2025', 9),
  ('Jake', 'Williams', 'jake@example.com', '$2a$12$ZylpiL9Cn/Emf7W5/dpizeDEvZDniwJsEnicRLAkRodkYIj5q1Tou', 1, 5550001111, '505 Volunteer Ln, Denver, CO 80201', 'VOL-005-2025', 10);

UPDATE "location" SET "victim_id" = 1 WHERE "id" = 1;
UPDATE "location" SET "victim_id" = 2 WHERE "id" = 2;
UPDATE "location" SET "victim_id" = 3 WHERE "id" = 3;
UPDATE "location" SET "victim_id" = 4 WHERE "id" = 4;
UPDATE "location" SET "victim_id" = 5 WHERE "id" = 5;
UPDATE "location" SET "volunteer_id" = 1 WHERE "id" = 6;
UPDATE "location" SET "volunteer_id" = 2 WHERE "id" = 7;
UPDATE "location" SET "volunteer_id" = 3 WHERE "id" = 8;
UPDATE "location" SET "volunteer_id" = 4 WHERE "id" = 9;
UPDATE "location" SET "volunteer_id" = 5 WHERE "id" = 10;

INSERT INTO "affected_zone" ("name", "description", "hazard_level", "admin_id") VALUES
  ('Flood Zone A', 'Areas along the eastern riverbank with significant flooding', 'High', 1),
  ('Wildfire Zone B', 'Forest areas in the northwest with ongoing wildfires', 'Critical', 2),
  ('Hurricane Impact C', 'Coastal regions affected by recent hurricane', 'Medium', 3),
  ('Earthquake Zone D', 'Areas with structural damage from recent earthquake', 'High', 1),
  ('Drought Region E', 'Agricultural areas affected by prolonged drought', 'Medium', 2);

INSERT INTO "affected_zone_location" ("affected_zone_id", "location_id") VALUES
  (1, 1), (1, 2), (1, 3),
  (2, 4), (2, 5), 
  (3, 6), (3, 7),
  (4, 8), (4, 9),
  (5, 10);

INSERT INTO "physical_donation" ("item_name", "description", "quantity", "item_type", "donation_date", "volunteer_id", "admin_id", "victim_id") VALUES
  ('Bottled Water', 'Cases of 24 water bottles', 50, 'Food', '2025-03-25 10:00:00', 1, NULL, NULL),
  ('First Aid Kits', 'Basic medical supplies', 20, 'Medicine', '2025-03-26 11:30:00', 2, NULL, NULL),
  ('Blankets', 'Warm wool blankets', 30, 'Clothes', '2025-03-27 09:15:00', 3, NULL, NULL),
  ('Canned Food', 'Assorted non-perishable food items', 100, 'Food', '2025-03-28 14:45:00', 4, NULL, NULL),
  ('Power Tools', 'Set of tools for rebuilding', 5, 'Tools', '2025-03-29 16:20:00', 5, NULL, NULL),
  ('Baby Formula', 'Infant nutrition supplies', 25, 'Food', '2025-03-30 08:30:00', NULL, 1, NULL),
  ('Tents', 'Temporary shelter', 15, 'Other', '2025-03-31 13:10:00', NULL, 2, NULL),
  ('Medications', 'Assorted over-the-counter medicines', 40, 'Medicine', '2025-04-01 10:45:00', NULL, 3, NULL);

INSERT INTO "monetary_donation" ("amount", "currency", "payment_status", "transaction_id", "payment_service", "donation_date", "volunteer_id", "admin_id", "victim_id") VALUES
  (500.00, 'USD', 'Completed', 'TXN-2025-001', 'PayPal', '2025-03-25 10:30:00', 1, NULL, NULL),
  (1000.00, 'USD', 'Completed', 'TXN-2025-002', 'CreditCard', '2025-03-26 11:45:00', 2, NULL, NULL),
  (750.00, 'EUR', 'Completed', 'TXN-2025-003', 'BankTransfer', '2025-03-27 09:30:00', 3, NULL, NULL),
  (300.00, 'USD', 'Completed', 'TXN-2025-004', 'PayPal', '2025-03-28 15:00:00', 4, NULL, NULL),
  (2000.00, 'USD', 'Completed', 'TXN-2025-005', 'CreditCard', '2025-03-29 16:35:00', 5, NULL, NULL),
  (5000.00, 'USD', 'Completed', 'TXN-2025-006', 'BankTransfer', '2025-03-30 08:45:00', NULL, 1, NULL),
  (3500.00, 'EUR', 'Completed', 'TXN-2025-007', 'PayPal', '2025-03-31 13:25:00', NULL, 2, NULL);

INSERT INTO "place" ("name", "admin_id") VALUES
  ('Community Center Alpha', 1),
  ('School Shelter Beta', 2),
  ('Hospital Aid Station', 3),
  ('Sports Arena Gamma', 1),
  ('Church Refuge Delta', 2);

INSERT INTO "place_affected_zone" ("place_id", "affected_zone_id") VALUES
  (1, 1), (1, 2),
  (2, 3), (2, 4),
  (3, 5), (3, 1),
  (4, 2), (4, 3),
  (5, 4), (5, 5);

INSERT INTO "skill" ("name", "level", "admin_id") VALUES
  ('First Aid', 'Intermediate', 1),
  ('Heavy Lifting', 'Beginner', 2),
  ('Cooking', 'Expert', 3),
  ('Construction', 'Intermediate', 1),
  ('Child Care', 'Beginner', 2),
  ('Medical Doctor', 'Expert', 3),
  ('Truck Driving', 'Intermediate', 1),
  ('Counseling', 'Expert', 2);

INSERT INTO "task" ("name", "description", "admin_id", "location_id") VALUES
  ('Distribute Water', 'Hand out bottled water to affected residents', 1, 11),
  ('Medical Assessment', 'Perform basic health checks on shelter residents', 2, 12),
  ('Debris Clearing', 'Clear fallen trees and debris from roads', 3, 13),
  ('Food Service', 'Prepare and serve meals at the community center', 1, 14),
  ('Child Care Shift', 'Supervise children at the shelter', 2, 15);

INSERT INTO "task_time" ("start_time", "end_time", "date", "task_id") VALUES
  ('08:00:00', '12:00:00', '2025-04-15', 1),
  ('13:00:00', '17:00:00', '2025-04-15', 1),
  ('09:00:00', '15:00:00', '2025-04-16', 2),
  ('08:00:00', '14:00:00', '2025-04-17', 3),
  ('11:00:00', '15:00:00', '2025-04-18', 4),
  ('09:00:00', '13:00:00', '2025-04-19', 5);

INSERT INTO "volunteer_time" ("start_time", "end_time", "day", "volunteer_id") VALUES
  ('08:00:00', '17:00:00', 'Monday', 1),
  ('08:00:00', '17:00:00', 'Wednesday', 1),
  ('08:00:00', '17:00:00', 'Friday', 1),
  ('09:00:00', '18:00:00', 'Tuesday', 2),
  ('09:00:00', '18:00:00', 'Thursday', 2),
  ('10:00:00', '16:00:00', 'Saturday', 3),
  ('10:00:00', '16:00:00', 'Sunday', 3),
  ('08:00:00', '12:00:00', 'Monday', 4),
  ('13:00:00', '17:00:00', 'Wednesday', 4),
  ('09:00:00', '15:00:00', 'Friday', 5);

INSERT INTO "need_type" ("name", "admin_id") VALUES
  ('Food and Water', 1),
  ('Medical Supplies', 2),
  ('Shelter', 3),
  ('Transportation', 1),
  ('Childcare', 2);

INSERT INTO "need" ("name", "description", "urgency_level", "victim_id", "admin_id") VALUES
  ('Emergency Food', 'Family of 4 needs food supplies', 'High', 1, NULL),
  ('Medication Refill', 'Need insulin refill within 48 hours', 'Critical', 2, NULL),
  ('Temporary Housing', 'Home damaged, needs shelter for 2 weeks', 'Medium', 3, NULL),
  ('Evacuation Transport', 'Elderly couple needs transportation from flood zone', 'High', 4, NULL),
  ('Baby Supplies', 'Need formula and diapers for infant', 'Medium', 5, NULL),
  ('Community Kitchen', 'Central food distribution point needed', 'Medium', NULL, 1);

INSERT INTO "need_need_type" ("need_id", "need_type_id") VALUES
  (1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 1);

INSERT INTO "need_task" ("need_id", "task_id") VALUES
  (1, 1), (1, 4), (2, 2), (3, 3), (5, 5), (6, 4);

INSERT INTO "volunteer_skill" ("volunteer_id", "skill_id") VALUES
  (1, 1), (1, 3), (1, 5),
  (2, 2), (2, 4), (2, 6),
  (3, 3), (3, 7),
  (4, 4), (4, 8),
  (5, 5), (5, 1);

INSERT INTO "task_skill" ("task_id", "skill_id") VALUES
  (1, 2), (1, 7),
  (2, 1), (2, 6),
  (3, 2), (3, 4),
  (4, 3),
  (5, 5), (5, 8);

INSERT INTO "need_skill" ("need_id", "skill_id") VALUES
  (1, 3), (2, 1), (2, 6), (3, 4), (4, 7), (5, 5), (6, 3);

INSERT INTO "volunteer_task" ("volunteer_id", "task_id", "state") VALUES
  (1, 1, 'Assigned'),
  (2, 2, 'Pending'),
  (3, 3, 'Completed'),
  (4, 4, 'Assigned'),
  (5, 5, 'Assigned');

INSERT INTO "volunteer_place" ("volunteer_id", "place_id") VALUES
  (1, 1), (1, 3),
  (2, 2), (2, 4),
  (3, 3), (3, 5),
  (4, 1), (4, 5),
  (5, 2), (5, 4);

INSERT INTO "route" ("name", "description", "hazard_level", "transport_type", "admin_id", "start_location_id", "end_location_id") VALUES
  ('Rescue Route Alpha', 'Path from Community Center to Hospital', 'Medium', 'Car', 1, 1, 3),
  ('Supply Route Beta', 'Safe path for supply trucks', 'Low', 'Boat', 2, 2, 4),
  ('Evacuation Route Gamma', 'Route for citizens to evacuate flood zone', 'High', 'Car', 3, 5, 7),
  ('Emergency Route Delta', 'Fast route for emergency vehicles', 'Medium', 'Car', 1, 8, 10),
  ('Alternate Path Epsilon', 'Secondary route if main roads blocked', 'Medium', 'Foot', 2, 11, 15);

INSERT INTO "route_location" ("route_id", "location_id") VALUES
  (1, 2), (1, 4),
  (2, 3), (2, 5),
  (3, 6), (3, 8),
  (4, 9), (4, 11),
  (5, 12), (5, 13), (5, 14);

INSERT INTO "task_donation" ("task_id", "donation_id") VALUES
  (1, 1), (2, 2), (2, 8), (3, 5), (4, 3), (4, 4), (5, 6);