INSERT INTO "location" ("latitude", "longitude") VALUES
  (39.4699, -0.3763),  -- Plaza del Ayuntamiento
  (39.4783, -0.3767),  -- Jardines del Real (Viveros)
  (39.4557, -0.3521),  -- Ciudad de las Artes y las Ciencias
  (39.4715, -0.3677),  -- Mercado Central
  (39.4735, -0.3787),  -- Torres de Serranos
  (39.4632, -0.3795),  -- Estación del Norte
  (39.4698, -0.3779),  -- Plaza de la Reina
  (39.4744, -0.3798),  -- Torres de Quart
  (39.4561, -0.3419),  -- Oceanogràfic
  (39.4789, -0.3676),  -- Jardín Botánico
  (39.4736, -0.3583),  -- Puerto de Valencia
  (39.4852, -0.3504),  -- Playa de la Malvarrosa
  (39.4581, -0.3322),  -- Puerto Este
  (39.4803, -0.3407),  -- Playa de las Arenas
  (39.4650, -0.3773),
  (39.4860, -0.3557),  -- Plaza de Benimaclet
  (39.4845, -0.3571),  -- Calle Emilio Baró
  (39.4853, -0.3543);  -- Estación de Benimaclet

INSERT INTO "admin" ("name", "surname", "email", "password", "prefix", "phone_number", "address", "identification", "jurisdiction") VALUES
  ('John', 'Smith', 'admin1@solidarityhub.org', '$2a$12$tzXOz0COG7QQnANfJK3peuSsC1Eu2UvE/jBZLWrZkT7XhY6GD7Cji', 1, '5551234567', '123 Admin St, New York, NY 10001', 'ADM-001-2025', 'New York State'),
  ('Maria', 'Garcia', 'admin2@solidarityhub.org', '$2a$12$MDiUeuDPHxOQ1szQ1bdYoOQuV9AfBnY99CwgZA7brFoJMdT.JiWXO', 1, '5552345678', '456 Admin Ave, Los Angeles, CA 90001', 'ADM-002-2025', 'California'),
  ('David', 'Johnson', 'admin3@solidarityhub.org', '$2a$12$8kP5X1y/rH6LYOQnRtNY3uXjOBDw9T4k0tC0TtndTqgf7hOESOUWa', 1, '5553456789', '789 Admin Blvd, Chicago, IL 60601', 'ADM-003-2025', 'Illinois'),
  ('Admin', 'Admin', 'admin@admin.admin','admin', 1, '5554567890', '123 Admin St, New York, NY 10001', 'ADM-004-2025', 'New York State');

INSERT INTO "victim" ("name", "surname", "email", "password", "prefix", "phone_number", "address", "identification", "location_id") VALUES
  ('Alice', 'Wilson', 'alice@example.com', '$2a$12$gK6ByD5rYpjKXKPwjQF0y.ZTqJawPmPE/tvyWG9Jd02mHynm7RhLG', 1, '5551112222', '101 Victim St, New York, NY 10001', 'VCT-001-2025', 1),
  ('Bob', 'Martinez', 'bob@example.com', '$2a$12$1Wmcp3eV9hMMKCC14banc.GQ3.qW8wroD582CGnuVrA.tgm0W8REK', 1, '5552223333', '202 Victim Ave, Los Angeles, CA 90001', 'VCT-002-2025', 2),
  ('Carol', 'Taylor', 'carol@example.com', '$2a$12$0VT37J97D356KoQ8ZS2NAen4x5NAKWaYkNBYl/LGBSB7AeNnuY4XG', 1, '5553334444', '303 Victim Blvd, Chicago, IL 60601', 'VCT-003-2025', 3),
  ('Devin', 'Brown', 'devin@example.com', '$2a$12$eOKsPJL6PYJ/U1F9MFjgIuhiDybZXBZRrRsPaeIplk0Y9Xf.d2IXK', 1, '5554445555', '404 Victim Dr, Houston, TX 77001', 'VCT-004-2025', 4),
  ('Eva', 'Davis', 'eva@example.com', '$2a$12$KmS5FBVMmQXwDB20zcCwGO8c7o.Omht5LdK6QerZ8IFaGGlJxqCCO', 1, '5555556666', '505 Victim Ln, Phoenix, AZ 85001', 'VCT-005-2025', 5);

INSERT INTO "volunteer" ("name", "surname", "email", "password", "prefix", "phone_number", "address", "identification", "location_id") VALUES
  ('Frank', 'Lee', 'frank@example.com', '$2a$12$1V.4auSYXgNH2xAqE93aS.LuDHpti6ldZZThDSM0VvrogryE8W0Ui', 1, '5556667777', '101 Volunteer St, Philadelphia, PA 19101', 'VOL-001-2025', 6),
  ('Grace', 'Kim', 'grace@example.com', '$2a$12$iDfI0RWwfUEwEc7MDYZpsOD6vFylnT1gSkl3rF8IC.mtQMQKytrXG', 1, '5557778888', '202 Volunteer Ave, San Diego, CA 92101', 'VOL-002-2025', 7),
  ('Henry', 'Chen', 'henry@example.com', '$2a$12$T3OQ8bab.LX/YzJYYFW5N.ww8GfrFYdpLrHhD45ZJKg5D0rAgZlS2', 1, '5558889999', '303 Volunteer Blvd, San Francisco, CA 94101', 'VOL-003-2025', 8),
  ('Isabel', 'Lopez', 'isabel@example.com', '$2a$12$Hb3xZZWmPDyz6mTkD1qF9.K3ayAr0bd97UQJMc2lUvqQs8Idz3XYi', 1, '5559990000', '404 Volunteer Dr, Austin, TX 78701', 'VOL-004-2025', 9),
  ('Jake', 'Williams', 'jake@example.com', '$2a$12$ZylpiL9Cn/Emf7W5/dpizeDEvZDniwJsEnicRLAkRodkYIj5q1Tou', 1, '5550001111', '505 Volunteer Ln, Denver, CO 80201', 'VOL-005-2025', 10);

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
  ('Zona de Inundación A', 'Áreas a lo largo del río con inundaciones significativas', 'High', 1),
  ('Zona de Incendio B', 'Áreas forestales del noroeste con incendios activos', 'Critical', 2),
  ('Zona de Huracán C', 'Regiones costeras afectadas por huracán reciente', 'Medium', 3),
  ('Zona de Terremoto D', 'Áreas con daños estructurales por terremoto reciente', 'High', 1),
  ('Región de Sequía E', 'Zonas agrícolas afectadas por sequía prolongada', 'Medium', 2),
  ('Zona Afectada Benimaclet', 'Área residencial con daños por temporal', 'None', 1);

INSERT INTO "affected_zone_location" ("affected_zone_id", "location_id") VALUES
  (1, 1), (1, 2), (1, 3),
  (2, 4), (2, 5), 
  (3, 6), (3, 7),
  (4, 8), (4, 9),
  (5, 10),
  (6, 16), (6, 17), (6, 18);

INSERT INTO "physical_donation" ("item_name", "description", "quantity", "item_type", "donation_date", "volunteer_id", "admin_id", "victim_id") VALUES
  ('Agua Embotellada', 'Cajas de 24 botellas de agua', 50, 'Food', '2025-03-25 10:00:00', 1, NULL, NULL),
  ('Botiquines', 'Suministros médicos básicos', 20, 'Medicine', '2025-03-26 11:30:00', 2, NULL, NULL),
  ('Mantas', 'Mantas de lana calientes', 30, 'Clothes', '2025-03-27 09:15:00', 3, NULL, NULL),
  ('Comida Enlatada', 'Alimentos no perecederos surtidos', 100, 'Food', '2025-03-28 14:45:00', 4, NULL, NULL),
  ('Herramientas Eléctricas', 'Conjunto de herramientas para reconstrucción', 5, 'Tools', '2025-03-29 16:20:00', 5, NULL, NULL),
  ('Fórmula para Bebés', 'Suministros de nutrición infantil', 25, 'Food', '2025-03-30 08:30:00', NULL, 1, NULL),
  ('Tiendas de Campaña', 'Refugio temporal', 15, 'Other', '2025-03-31 13:10:00', NULL, 2, NULL),
  ('Medicamentos', 'Medicamentos variados sin receta', 40, 'Medicine', '2025-04-01 10:45:00', NULL, 3, NULL);

INSERT INTO "monetary_donation" ("amount", "currency", "payment_status", "transaction_id", "payment_service", "donation_date", "volunteer_id", "admin_id", "victim_id") VALUES
  (500.00, 'USD', 'Completed', 'TXN-2025-001', 'PayPal', '2025-03-25 10:30:00', 1, NULL, NULL),
  (1000.00, 'USD', 'Completed', 'TXN-2025-002', 'CreditCard', '2025-03-26 11:45:00', 2, NULL, NULL),
  (750.00, 'EUR', 'Completed', 'TXN-2025-003', 'BankTransfer', '2025-03-27 09:30:00', 3, NULL, NULL),
  (300.00, 'USD', 'Completed', 'TXN-2025-004', 'PayPal', '2025-03-28 15:00:00', 4, NULL, NULL),
  (2000.00, 'USD', 'Completed', 'TXN-2025-005', 'CreditCard', '2025-03-29 16:35:00', 5, NULL, NULL),
  (5000.00, 'USD', 'Completed', 'TXN-2025-006', 'BankTransfer', '2025-03-30 08:45:00', NULL, 1, NULL),
  (3500.00, 'EUR', 'Completed', 'TXN-2025-007', 'PayPal', '2025-03-31 13:25:00', NULL, 2, NULL);

INSERT INTO "place" ("name", "admin_id") VALUES
  ('Centro Comunitario Alfa', 1),
  ('Refugio Escolar Beta', 2),
  ('Estación de Ayuda Hospital', 3),
  ('Arena Deportiva Gamma', 1),
  ('Refugio Iglesia Delta', 2);

INSERT INTO "place_affected_zone" ("place_id", "affected_zone_id") VALUES
  (1, 1), (1, 2),
  (2, 3), (2, 4),
  (3, 5), (3, 1),
  (4, 2), (4, 3),
  (5, 4), (5, 5);

INSERT INTO "skill" ("name", "level", "admin_id") VALUES
  ('Primeros Auxilios', 'Intermediate', 1),
  ('Levantamiento de Peso', 'Beginner', 2),
  ('Cocina', 'Expert', 3),
  ('Construcción', 'Intermediate', 1),
  ('Cuidado Infantil', 'Beginner', 2),
  ('Médico', 'Expert', 3),
  ('Conducción de Camiones', 'Intermediate', 1),
  ('Consejería', 'Expert', 2);

INSERT INTO "task" ("name", "description", "admin_id", "location_id", "start_date", "end_date") VALUES
  ('Distribuir Agua', 'Repartir agua embotellada a residentes afectados', 1, 11, '2025-04-15 08:00:00', null),
  ('Evaluación Médica', 'Realizar chequeos básicos de salud a residentes del refugio', 2, 12, '2025-04-16 09:00:00', '2025-04-16 15:00:00'),
  ('Limpieza de Escombros', 'Limpiar árboles caídos y escombros de las carreteras', 3, 13, '2025-04-17 08:00:00', null),
  ('Servicio de Comida', 'Preparar y servir comidas en el centro comunitario', 1, 14, '2025-04-18 11:00:00', '2025-04-18 15:00:00'),
  ('Turno de Cuidado Infantil', 'Supervisar niños en el refugio', 2, 15, '2025-04-19 09:00:00', '2025-04-19 13:00:00');

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
  ('Comida y Agua', 1),
  ('Suministros Médicos', 2),
  ('Refugio', 3),
  ('Transporte', 1),
  ('Cuidado Infantil', 2);

INSERT INTO "need" ("name", "description", "urgency_level", "victim_id", "admin_id") VALUES
  ('Comida de Emergencia', 'Familia de 4 necesita suministros de comida', 'High', 1, NULL),
  ('Reposición de Medicamentos', 'Necesita reposición de insulina en 48 horas', 'Critical', 2, NULL),
  ('Vivienda Temporal', 'Casa dañada, necesita refugio por 2 semanas', 'Medium', 3, NULL),
  ('Transporte de Evacuación', 'Pareja de ancianos necesita transporte desde zona inundada', 'High', 4, NULL),
  ('Suministros para Bebé', 'Necesita fórmula y pañales para bebé', 'Medium', 5, NULL),
  ('Cocina Comunitaria', 'Se necesita punto central de distribución de alimentos', 'Medium', NULL, 1);

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

UPDATE victim 
SET created_at = CASE 
    WHEN id = 1 THEN CURRENT_TIMESTAMP - INTERVAL '7 days'
    WHEN id IN (2, 3) THEN CURRENT_TIMESTAMP - INTERVAL '2 days'
    ELSE created_at
END;
