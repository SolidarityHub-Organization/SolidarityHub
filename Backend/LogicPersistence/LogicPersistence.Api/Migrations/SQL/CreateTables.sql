/* enums */
CREATE TYPE skill_level AS ENUM (
    'Unknown',
    'Beginner',
    'Intermediate',
    'Expert'
);
CREATE TYPE hazard_level AS ENUM (
    'Unknown',
    'Low',
    'Medium',
    'High',
    'Critical'
);
CREATE TYPE item_type AS ENUM (
    'Other',
    'Food',
    'Tools',
    'Clothes',
    'Medicine',
    'Furniture'
);
CREATE TYPE currency AS ENUM (
    'Other',
    'USD',
    'EUR'
);
CREATE TYPE payment_status AS ENUM (
    'Pending',
    'Completed',
    'Failed',
    'Refunded'
);
CREATE TYPE payment_service AS ENUM (
    'Other',
    'PayPal',
    'BankTransfer',
    'CreditCard'
);
CREATE TYPE day_of_week AS ENUM (
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
);
CREATE TYPE urgency_level AS ENUM (
    'Unknown',
    'Low',
    'Medium',
    'High',
    'Critical'
);
CREATE TYPE transport_type AS ENUM (
    'Other',
    'Car',
    'Bike',
    'Foot',
    'Boat',
    'Plane',
    'Train'
);


/* main tables */

CREATE TABLE IF NOT EXISTS "volunteer" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "surname" VARCHAR(255) NOT NULL,
    "email" VARCHAR(255) UNIQUE NOT NULL,
    "password" VARCHAR(255) NOT NULL,
    "prefix" INT NOT NULL,
    "phone_number" INT NOT NULL,
    "address" VARCHAR(255) NOT NULL,
    "identification" VARCHAR(255) NOT NULL,
    "location_id" INT,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY ("location_id") REFERENCES "location"("id")
);
CREATE UNIQUE INDEX unique_volunteer_location_not_null ON volunteer(location_id) WHERE location_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS "victim" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "surname" VARCHAR(255) NOT NULL,
    "email" VARCHAR(255) UNIQUE NOT NULL,
    "password" VARCHAR(255) NOT NULL,
    "prefix" INT NOT NULL,
    "phone_number" INT NOT NULL,
    "address" VARCHAR(255) NOT NULL,
    "identification" VARCHAR(255) NOT NULL,
    "location_id" INT,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY ("location_id") REFERENCES "location"("id")
);
CREATE UNIQUE INDEX unique_victim_location_not_null ON victim(location_id) WHERE location_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS "admin" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "surname" VARCHAR(255) NOT NULL,
    "email" VARCHAR(255) UNIQUE NOT NULL,
    "password" VARCHAR(255) NOT NULL,
    "prefix" INT NOT NULL,
    "phone_number" INT NOT NULL,
    "address" VARCHAR(255) NOT NULL,
    "identification" VARCHAR(255) NOT NULL,
    "jurisdiction" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "location" (
    "id" SERIAL PRIMARY KEY,
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "victim_id" INT,
    "volunteer_id" INT,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE UNIQUE INDEX unique_location_victim_not_null ON location(victim_id) WHERE victim_id IS NOT NULL;
CREATE UNIQUE INDEX unique_location_volunteer_not_null ON location(volunteer_id) WHERE volunteer_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS "affected_zone" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "description" VARCHAR(1000) NOT NULL,
    "hazard_level" hazard_level NOT NULL,
    "admin_id" INT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--donation tables
CREATE TABLE IF NOT EXISTS "physical_donation" (
    "id" SERIAL PRIMARY KEY,
    "donation_date" TIMESTAMP NOT NULL,
    "volunteer_id" INT,
    "admin_id" INT,
    "victim_id" INT,

    "item_name" VARCHAR(255) NOT NULL,
    "description" VARCHAR(1000) NOT NULL,
    "quantity" INT NOT NULL CHECK (quantity > 0),
    "item_type" item_type NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY ("volunteer_id") REFERENCES "volunteer"("id"),
    FOREIGN KEY ("admin_id") REFERENCES "admin"("id"),
    FOREIGN KEY ("victim_id") REFERENCES "victim"("id")
);
CREATE TABLE IF NOT EXISTS "monetary_donation" (
    "id" SERIAL PRIMARY KEY,
    "donation_date" TIMESTAMP NOT NULL,
    "volunteer_id" INT,
    "admin_id" INT,
    "victim_id" INT,

    "amount" DECIMAL(18, 2) NOT NULL CHECK (amount > 0),
    "currency" currency NOT NULL,
    "payment_status" payment_status NOT NULL,
    "transaction_id" VARCHAR(255) NOT NULL,
    "payment_service" payment_service NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY ("volunteer_id") REFERENCES "volunteer"("id"),
    FOREIGN KEY ("admin_id") REFERENCES "admin"("id"),
    FOREIGN KEY ("victim_id") REFERENCES "victim"("id")
);
--end of donation tables

--time tables
CREATE TABLE IF NOT EXISTS "task_time" (
    "id" SERIAL PRIMARY KEY,
    "start_time" TIME NOT NULL,
    "end_time" TIME NOT NULL,

    "date" DATE NOT NULL,
    "task_id" INT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY ("task_id") REFERENCES "task"("id")
);

CREATE TABLE IF NOT EXISTS "volunteer_time" (
    "id" SERIAL PRIMARY KEY,
    "start_time" TIME NOT NULL,
    "end_time" TIME NOT NULL,

    "day" day_of_week NOT NULL,
    "volunteer_id" INT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY ("volunteer_id") REFERENCES "volunteer"("id")
);
--end of time tables

CREATE TABLE IF NOT EXISTS "task" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "description" VARCHAR(1000) NOT NULL,
    "admin_id" INT,
    "location_id" INT NOT NULL,
    "start_date" TIMESTAMP NOT NULL,
    "end_date" TIMESTAMP,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY ("admin_id") REFERENCES "admin"("id"),
    FOREIGN KEY ("location_id") REFERENCES "location"("id")
);

CREATE TABLE IF NOT EXISTS "need" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "description" VARCHAR(1000) NOT NULL,
    "urgency_level" urgency_level NOT NULL,
    "victim_id" INT,
    "admin_id" INT,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY ("victim_id") REFERENCES "victim"("id"),
    FOREIGN KEY ("admin_id") REFERENCES "admin"("id")
);

CREATE TABLE IF NOT EXISTS "need_type" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "admin_id" INT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY ("admin_id") REFERENCES "admin"("id")
);

CREATE TABLE IF NOT EXISTS "place" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "admin_id" INT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY ("admin_id") REFERENCES "admin"("id")
);

CREATE TABLE IF NOT EXISTS "route" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "description" VARCHAR(1000) NOT NULL,
    "hazard_level" hazard_level NOT NULL,
    "transport_type" transport_type NOT NULL,
    "admin_id" INT,
    "start_location_id" INT NOT NULL,
    "end_location_id" INT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY ("admin_id") REFERENCES "admin"("id"),
    FOREIGN KEY ("start_location_id") REFERENCES "location"("id"),
    FOREIGN KEY ("end_location_id") REFERENCES "location"("id")
);

CREATE TABLE IF NOT EXISTS "skill" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "level" skill_level NOT NULL,
    "admin_id" INT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY ("admin_id") REFERENCES "admin"("id")
);

CREATE TABLE IF NOT EXISTS "notifications" (
    "id" SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "description" VARCHAR(1000) NOT NULL,
    "volunteer_id" INT,
    "victim_id" INT,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY ("volunteer_id") REFERENCES "volunteer"("id") ON DELETE CASCADE,
    FOREIGN KEY ("victim_id") REFERENCES "victim"("id") ON DELETE CASCADE,
    CHECK (
        ("volunteer_id" IS NOT NULL AND "victim_id" IS NULL) OR
        ("volunteer_id" IS NULL AND "victim_id" IS NOT NULL)
    )
);


/* intermediate tables */

CREATE TABLE IF NOT EXISTS "volunteer_skill" (
    "volunteer_id" INT NOT NULL,
    "skill_id" INT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY ("volunteer_id", "skill_id"),
    FOREIGN KEY ("volunteer_id") REFERENCES "volunteer"("id") ON DELETE CASCADE,
    FOREIGN KEY ("skill_id") REFERENCES "skill"("id") ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "volunteer_task" (
    "volunteer_id" INT NOT NULL,
    "task_id" INT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY ("volunteer_id", "task_id"),
    FOREIGN KEY ("volunteer_id") REFERENCES "volunteer"("id") ON DELETE CASCADE,
    FOREIGN KEY ("task_id") REFERENCES "task"("id") ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "volunteer_place" (
    "volunteer_id" INT NOT NULL,
    "place_id" INT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY ("volunteer_id", "place_id"),
    FOREIGN KEY ("volunteer_id") REFERENCES "volunteer"("id") ON DELETE CASCADE,
    FOREIGN KEY ("place_id") REFERENCES "place"("id") ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "task_skill" (
    "task_id" INT NOT NULL,
    "skill_id" INT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY ("task_id", "skill_id"),
    FOREIGN KEY ("task_id") REFERENCES "task"("id") ON DELETE CASCADE,
    FOREIGN KEY ("skill_id") REFERENCES "skill"("id") ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "task_donation" (
    "task_id" INT NOT NULL,
    "donation_id" INT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY ("task_id", "donation_id"),
    FOREIGN KEY ("task_id") REFERENCES "task"("id") ON DELETE CASCADE,
    FOREIGN KEY ("donation_id") REFERENCES "physical_donation"("id") ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "route_location" (
    "route_id" INT NOT NULL,
    "location_id" INT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY ("route_id", "location_id"),
    FOREIGN KEY ("route_id") REFERENCES "route"("id") ON DELETE CASCADE,
    FOREIGN KEY ("location_id") REFERENCES "location"("id") ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "place_affected_zone" (
    "place_id" INT NOT NULL,
    "affected_zone_id" INT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY ("place_id", "affected_zone_id"),
    FOREIGN KEY ("place_id") REFERENCES "place"("id") ON DELETE CASCADE,
    FOREIGN KEY ("affected_zone_id") REFERENCES "affected_zone"("id") ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "need_task" (
    "need_id" INT NOT NULL,
    "task_id" INT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY ("need_id", "task_id"),
    FOREIGN KEY ("need_id") REFERENCES "need"("id") ON DELETE CASCADE,
    FOREIGN KEY ("task_id") REFERENCES "task"("id") ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "need_skill" (
    "need_id" INT NOT NULL,
    "skill_id" INT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY ("need_id", "skill_id"),
    FOREIGN KEY ("need_id") REFERENCES "need"("id") ON DELETE CASCADE,
    FOREIGN KEY ("skill_id") REFERENCES "skill"("id") ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "need_need_type" (
    "need_id" INT NOT NULL,
    "need_type_id" INT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY ("need_id", "need_type_id"),
    FOREIGN KEY ("need_id") REFERENCES "need"("id") ON DELETE CASCADE,
    FOREIGN KEY ("need_type_id") REFERENCES "need_type"("id") ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "affected_zone_location" (
    "affected_zone_id" INT NOT NULL,
    "location_id" INT NOT NULL,
    "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY ("affected_zone_id", "location_id"),
    FOREIGN KEY ("affected_zone_id") REFERENCES "affected_zone"("id") ON DELETE CASCADE,
    FOREIGN KEY ("location_id") REFERENCES "location"("id") ON DELETE CASCADE
);
