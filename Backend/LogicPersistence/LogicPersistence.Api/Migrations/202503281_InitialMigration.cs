using FluentMigrator;

// When modifying the structure of the database, another file similar to this one must be created,
// the method Up() implements the modifications, and the method Down() deletes those modifications

[Migration(202503281)]
public class InitialMigration : Migration {
	public override void Up() {
		// Create the schema for the database
		Execute.Sql("CREATE SCHEMA IF NOT EXISTS public;");

		// Create the required types (enums) for some parameters in the tables
		Execute.Sql(@"
			DO $$
			BEGIN
				IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'hazard_level') THEN
					CREATE TYPE hazard_level AS ENUM('unknown', 'low', 'medium', 'high', 'critical');
				END IF;

				IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'physical_donation_type') THEN
					CREATE TYPE physical_donation_type AS ENUM('other', 'food', 'tools', 'clothes', 'medicine', 'furniture');
				END IF;

				IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'currency') THEN
					CREATE TYPE currency AS ENUM('other', 'usd', 'eur');
				END IF;

				IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_status') THEN
					CREATE TYPE payment_status AS ENUM('pending', 'completed', 'failed', 'refunded');
				END IF;

				IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_service') THEN
					CREATE TYPE payment_service AS ENUM('paypal', 'bank_transfer', 'credit_card', 'other');
				END IF;

				IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'urgency_level') THEN
					CREATE TYPE urgency_level AS ENUM('unknown', 'low', 'medium', 'high', 'critical');
				END IF;

				IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'transport_type') THEN
					CREATE TYPE transport_type AS ENUM('other', 'car', 'bike', 'foot', 'boat', 'plane', 'train');
				END IF;

				IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'skill_level') THEN
					CREATE TYPE skill_level AS ENUM('unknown', 'beginner', 'intermediate', 'expert');
				END IF;

				IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'day_of_week') THEN
					CREATE TYPE day_of_week AS ENUM('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday');
				END IF;

				IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'state') THEN
					CREATE TYPE state AS ENUM('assigned', 'pending', 'completed', 'cancelled');
				END IF;
			END
			$$;
		");

		// Create every table in the database
		Create.Table("victim")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("email").AsString(50).NotNullable()
			.WithColumn("password").AsString(128).NotNullable()
			.WithColumn("name").AsString(50).NotNullable()
			.WithColumn("surname").AsString(50).NotNullable()
			.WithColumn("prefix").AsInt32().NotNullable()
			.WithColumn("phone_number").AsInt64().NotNullable()
			.WithColumn("address").AsString(100).NotNullable()
			.WithColumn("identification").AsString(20).NotNullable();

		Create.Table("volunteer")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("email").AsString(50).NotNullable()
			.WithColumn("password").AsString(128).NotNullable()
			.WithColumn("name").AsString(50).NotNullable()
			.WithColumn("surname").AsString(50).NotNullable()
			.WithColumn("prefix").AsInt32().NotNullable()
			.WithColumn("phone_number").AsInt64().NotNullable()
			.WithColumn("address").AsString(100).NotNullable()
			.WithColumn("identification").AsString(20).NotNullable();

		Create.Table("admin")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("jurisdiction").AsString(50).NotNullable()
			.WithColumn("email").AsString(50).NotNullable()
			.WithColumn("password").AsString(128).NotNullable()
			.WithColumn("name").AsString(50).NotNullable()
			.WithColumn("surname").AsString(50).NotNullable()
			.WithColumn("prefix").AsInt32().NotNullable()
			.WithColumn("phone_number").AsInt64().NotNullable()
			.WithColumn("address").AsString(100).NotNullable()
			.WithColumn("identification").AsString(20).NotNullable();

		Create.Table("affected_zone")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("name").AsString(50).NotNullable()
			.WithColumn("description").AsString(200).NotNullable()
			.WithColumn("hazard_level").AsCustom("hazard_level").NotNullable();

		Create.Table("donation")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("donation_date").AsDate().NotNullable();

		Create.Table("physical_donation")
			.WithColumn("item_name").AsString(50).NotNullable()
			.WithColumn("description").AsString(200).NotNullable()
			.WithColumn("quantity").AsInt32().NotNullable()
			.WithColumn("item_type").AsCustom("physical_donation_type").NotNullable();

		Create.Table("monetary_donation")
			.WithColumn("amount").AsDecimal().NotNullable()
			.WithColumn("currency").AsCustom("currency").NotNullable()
			.WithColumn("payment_status").AsCustom("payment_status").NotNullable()
			.WithColumn("transaction_id").AsString(20).NotNullable()
			.WithColumn("payment_service").AsCustom("payment_service").NotNullable();

		Create.Table("location")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("latitude").AsDouble().NotNullable()
			.WithColumn("longitude").AsDouble().NotNullable();

		Create.Table("need")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("name").AsString(50).NotNullable()
			.WithColumn("description").AsString(200).NotNullable()
			.WithColumn("urgency_level").AsCustom("urgency_level").NotNullable();

		Create.Table("place")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("name").AsString(50).NotNullable();

		Create.Table("route")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("name").AsString(50).NotNullable()
			.WithColumn("description").AsString(200).NotNullable()
			.WithColumn("hazard_level").AsCustom("hazard_level").NotNullable()
			.WithColumn("transport_type").AsCustom("transport_type").NotNullable();

		Create.Table("skill")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("name").AsString(50).NotNullable()
			.WithColumn("level").AsCustom("skill_level").NotNullable();

		Create.Table("task")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("name").AsString(50).NotNullable()
			.WithColumn("description").AsString(500).NotNullable();

		Create.Table("time")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("start_time").AsTime().NotNullable()
			.WithColumn("end_time").AsTime().NotNullable();

		Create.Table("task_time")
			.WithColumn("date").AsDate().NotNullable()
			.WithColumn("task_id").AsInt32().NotNullable();

		Create.Table("volunteer_time")
			.WithColumn("day").AsCustom("day_of_week").NotNullable()
			.WithColumn("volunteer_id").AsInt32().NotNullable();

		Create.Table("route_location")
			.WithColumn("route_id").AsInt32().NotNullable()
			.WithColumn("location_id").AsInt32().NotNullable();

		Create.Table("task_donation")
			.WithColumn("task_id").AsInt32().NotNullable()
			.WithColumn("donation_id").AsInt32().NotNullable();

		Create.Table("volunteer_place_preference")
			.WithColumn("volunteer_id").AsInt32().NotNullable()
			.WithColumn("place_preference_id").AsInt32().NotNullable();

		Create.Table("task_skill")
			.WithColumn("task_id").AsInt32().NotNullable()
			.WithColumn("skill_id").AsInt32().NotNullable();

		Create.Table("volunteer_skill")
			.WithColumn("volunteer_id").AsInt32().NotNullable()
			.WithColumn("skill_id").AsInt32().NotNullable();

		Create.Table("volunteer_task")
			.WithColumn("volunteer_id").AsInt32().NotNullable()
			.WithColumn("task_id").AsInt32().NotNullable()
			.WithColumn("state").AsCustom("state").NotNullable();

		Create.Table("affected_zone_location")
			.WithColumn("location_id").AsInt32().NotNullable()
			.WithColumn("affected_zone_id").AsInt32().NotNullable();

		Create.Table("need_skill")
			.WithColumn("need_id").AsInt32().NotNullable()
			.WithColumn("skill_id").AsInt32().NotNullable();

		Create.Table("need_task")
			.WithColumn("need_id").AsInt32().NotNullable()
			.WithColumn("task_id").AsInt32().NotNullable();

		Create.Table("place_affected_zone")
			.WithColumn("place_id").AsInt32().NotNullable()
			.WithColumn("affected_zone_id").AsInt32().NotNullable();

		// Create foreign key relations for the tables
		Create.ForeignKey("FK_Admin_AffectedZone")
			.FromTable("help_request").ForeignColumn("victim_id")
			.ToTable("victim").PrimaryColumn("id");
	}

	public override void Down() {
		// Delete tables (in inverse order with respect to creation)
		Delete.Table("place_affected_zone");
		Delete.Table("need_task");
		Delete.Table("need_skill");
		Delete.Table("affected_zone_location");
		Delete.Table("volunteer_task");
		Delete.Table("volunteer_skill");
		Delete.Table("task_skill");
		Delete.Table("volunteer_place_preference");
		Delete.Table("task_donation");
		Delete.Table("route_location");
		Delete.Table("volunteer_time");
		Delete.Table("task_time");
		Delete.Table("time");
		Delete.Table("task");
		Delete.Table("skill");
		Delete.Table("route");
		Delete.Table("place");
		Delete.Table("need");
		Delete.Table("location");
		Delete.Table("monetary_donation");
		Delete.Table("physical_donation");
		Delete.Table("donation");
		Delete.Table("affected_zone");
		Delete.Table("admin");
		Delete.Table("volunteer");
		Delete.Table("victim");

		// Delete types (enums) created (in inverse order with respect to creation)
		Execute.Sql("DROP TYPE IF EXISTS state CASCADE;");
		Execute.Sql("DROP TYPE IF EXISTS day_of_week CASCADE;");
		Execute.Sql("DROP TYPE IF EXISTS skill_level CASCADE;");
		Execute.Sql("DROP TYPE IF EXISTS transport_type CASCADE;");
		Execute.Sql("DROP TYPE IF EXISTS urgency_level CASCADE;");
		Execute.Sql("DROP TYPE IF EXISTS currency CASCADE;");
		Execute.Sql("DROP TYPE IF EXISTS payment_service CASCADE;");
		Execute.Sql("DROP TYPE IF EXISTS payment_status CASCADE;");
		Execute.Sql("DROP TYPE IF EXISTS physical_donation_type CASCADE;");
		Execute.Sql("DROP TYPE IF EXISTS hazard_level CASCADE;");

		// Delete schema
		Execute.Sql("DROP SCHEMA IF EXISTS public CASCADE;");
	}
}
