using System.Data;
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
					CREATE TYPE hazard_level AS ENUM ('Unknown', 'None', 'Low', 'Medium', 'High', 'Critical');
				END IF;

				IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'item_type') THEN
					CREATE TYPE item_type AS ENUM ('Other', 'Food', 'Tools', 'Clothes', 'Medicine', 'Furniture');
				END IF;

				IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'currency') THEN
					CREATE TYPE currency AS ENUM ('Other', 'USD', 'EUR');
				END IF;

				IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_status') THEN
					CREATE TYPE payment_status AS ENUM ('Pending', 'Completed', 'Failed', 'Refunded');
				END IF;

				IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_service') THEN
					CREATE TYPE payment_service AS ENUM ('Other', 'PayPal', 'BankTransfer', 'CreditCard');
				END IF;

				IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'urgency_level') THEN
					CREATE TYPE urgency_level AS ENUM ('Unknown', 'Low', 'Medium', 'High', 'Critical');
				END IF;

				IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'transport_type') THEN
					CREATE TYPE transport_type AS ENUM ('Other', 'Car', 'Bike', 'Foot', 'Boat', 'Plane', 'Train');
				END IF;

				IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'skill_level') THEN
					CREATE TYPE skill_level AS ENUM ('Unknown', 'Beginner', 'Intermediate', 'Expert');
				END IF;

				IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'day_of_week') THEN
					CREATE TYPE day_of_week AS ENUM ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');
				END IF;

				IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'state') THEN
					CREATE TYPE state AS ENUM ('Assigned', 'Pending', 'Completed', 'Cancelled');
				END IF;
			END
			$$;
		");

		// Create location table first as it's referenced by many other tables
		Create.Table("location")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("latitude").AsDouble().NotNullable()
			.WithColumn("longitude").AsDouble().NotNullable()
			.WithColumn("victim_id").AsInt32().Nullable()
			.WithColumn("volunteer_id").AsInt32().Nullable()
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);
		Execute.Sql("CREATE UNIQUE INDEX unique_location_victim_not_null ON location(victim_id) WHERE victim_id IS NOT NULL;");
		Execute.Sql("CREATE UNIQUE INDEX unique_location_volunteer_not_null ON location(volunteer_id) WHERE volunteer_id IS NOT NULL;");

		// Create tables in proper order to maintain references
		Create.Table("victim")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("email").AsString(255).NotNullable().Unique()
			.WithColumn("password").AsString(255).NotNullable()
			.WithColumn("name").AsString(255).NotNullable()
			.WithColumn("surname").AsString(255).NotNullable()
			.WithColumn("prefix").AsInt32().NotNullable()
			.WithColumn("phone_number").AsString(255).NotNullable()
			.WithColumn("address").AsString(255).NotNullable()
			.WithColumn("identification").AsString(255).NotNullable()
			.WithColumn("location_id").AsInt32().Nullable().ForeignKey("FK_Victim_Location", "location", "id")
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);
		Execute.Sql("CREATE UNIQUE INDEX unique_victim_location_not_null ON victim(location_id) WHERE location_id IS NOT NULL;");

		Create.Table("volunteer")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("email").AsString(255).NotNullable().Unique()
			.WithColumn("password").AsString(255).NotNullable()
			.WithColumn("name").AsString(255).NotNullable()
			.WithColumn("surname").AsString(255).NotNullable()
			.WithColumn("prefix").AsInt32().NotNullable()
			.WithColumn("phone_number").AsString(255).NotNullable()
			.WithColumn("address").AsString(255).NotNullable()
			.WithColumn("identification").AsString(255).NotNullable()
			.WithColumn("location_id").AsInt32().Nullable().ForeignKey("FK_Volunteer_Location", "location", "id")
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);
		Execute.Sql("CREATE UNIQUE INDEX unique_volunteer_location_not_null ON volunteer(location_id) WHERE location_id IS NOT NULL;");

		Create.Table("admin")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("email").AsString(255).NotNullable().Unique()
			.WithColumn("password").AsString(255).NotNullable()
			.WithColumn("name").AsString(255).NotNullable()
			.WithColumn("surname").AsString(255).NotNullable()
			.WithColumn("prefix").AsInt32().NotNullable()
			.WithColumn("phone_number").AsString(255).NotNullable()
			.WithColumn("address").AsString(255).NotNullable()
			.WithColumn("identification").AsString(255).NotNullable()
			.WithColumn("jurisdiction").AsString(255).NotNullable()
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);

		Create.Table("affected_zone")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("name").AsString(255).NotNullable()
			.WithColumn("description").AsString(1000).NotNullable()
			.WithColumn("hazard_level").AsCustom("hazard_level").NotNullable()
			.WithColumn("admin_id").AsInt32().NotNullable().ForeignKey("FK_AffectedZone_Admin", "admin", "id")
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);

		Create.Table("physical_donation")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("item_name").AsString(255).NotNullable()
			.WithColumn("description").AsString(1000).NotNullable()
			.WithColumn("quantity").AsInt32().NotNullable()
			.WithColumn("item_type").AsCustom("item_type").NotNullable()
			.WithColumn("donation_date").AsDateTime().NotNullable()
			.WithColumn("volunteer_id").AsInt32().Nullable().ForeignKey("FK_PhysicalDonation_Volunteer", "volunteer", "id").OnDelete(Rule.SetNull)
			.WithColumn("admin_id").AsInt32().Nullable().ForeignKey("FK_PhysicalDonation_Admin", "admin", "id")
			.WithColumn("victim_id").AsInt32().Nullable().ForeignKey("FK_PhysicalDonation_Victim", "victim", "id").OnDelete(Rule.SetNull)
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);
		Execute.Sql("ALTER TABLE physical_donation ADD CONSTRAINT CK_physical_donation_quantity CHECK (quantity > 0);");

		Create.Table("monetary_donation")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("amount").AsDecimal(18, 2).NotNullable()
			.WithColumn("currency").AsCustom("currency").NotNullable()
			.WithColumn("payment_status").AsCustom("payment_status").NotNullable()
			.WithColumn("transaction_id").AsString(255).NotNullable()
			.WithColumn("payment_service").AsCustom("payment_service").NotNullable()
			.WithColumn("donation_date").AsDateTime().NotNullable()
			.WithColumn("volunteer_id").AsInt32().Nullable().ForeignKey("FK_MonetaryDonation_Volunteer", "volunteer", "id").OnDelete(Rule.SetNull)
			.WithColumn("admin_id").AsInt32().Nullable().ForeignKey("FK_MonetaryDonation_Admin", "admin", "id")
			.WithColumn("victim_id").AsInt32().Nullable().ForeignKey("FK_MonetaryDonation_Victim", "victim", "id").OnDelete(Rule.SetNull)
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);
		Execute.Sql("ALTER TABLE monetary_donation ADD CONSTRAINT CK_monetary_donation_amount CHECK (amount > 0);");

		Create.Table("place")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("name").AsString(255).NotNullable()
			.WithColumn("admin_id").AsInt32().NotNullable().ForeignKey("FK_Place_Admin", "admin", "id")
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);

		Create.Table("skill")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("name").AsString(255).NotNullable()
			.WithColumn("level").AsCustom("skill_level").NotNullable()
			.WithColumn("admin_id").AsInt32().NotNullable().ForeignKey("FK_Skill_Admin", "admin", "id")
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);

		Create.Table("task")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("name").AsString(255).NotNullable()
			.WithColumn("description").AsString(1000).NotNullable()
			.WithColumn("admin_id").AsInt32().Nullable().ForeignKey("FK_Task_Admin", "admin", "id")
			.WithColumn("location_id").AsInt32().NotNullable().ForeignKey("FK_Task_Location", "location", "id")
			.WithColumn("start_date").AsDateTime().NotNullable()
			.WithColumn("end_date").AsDateTime().Nullable()
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);

		Create.Table("need")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("name").AsString(255).NotNullable()
			.WithColumn("description").AsString(1000).NotNullable()
			.WithColumn("urgency_level").AsCustom("urgency_level").NotNullable()
			.WithColumn("victim_id").AsInt32().Nullable().ForeignKey("FK_Need_Victim", "victim", "id").OnDelete(Rule.Cascade)
			.WithColumn("admin_id").AsInt32().Nullable().ForeignKey("FK_Need_Admin", "admin", "id")
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);

		Create.Table("need_type")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("name").AsString(255).NotNullable()
			.WithColumn("admin_id").AsInt32().NotNullable().ForeignKey("FK_NeedType_Admin", "admin", "id")
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);

		Create.Table("route")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("name").AsString(255).NotNullable()
			.WithColumn("description").AsString(1000).NotNullable()
			.WithColumn("hazard_level").AsCustom("hazard_level").NotNullable()
			.WithColumn("transport_type").AsCustom("transport_type").NotNullable()
			.WithColumn("admin_id").AsInt32().Nullable().ForeignKey("FK_Route_Admin", "admin", "id")
			.WithColumn("start_location_id").AsInt32().NotNullable().ForeignKey("FK_Route_StartLocation", "location", "id")
			.WithColumn("end_location_id").AsInt32().NotNullable().ForeignKey("FK_Route_EndLocation", "location", "id")
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);

		// Create the time tables
		Create.Table("task_time")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("start_time").AsTime().NotNullable()
			.WithColumn("end_time").AsTime().NotNullable()
			.WithColumn("date").AsDate().NotNullable()
			.WithColumn("task_id").AsInt32().NotNullable().ForeignKey("FK_TaskTime_Task", "task", "id")
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);

		Create.Table("volunteer_time")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("start_time").AsTime().NotNullable()
			.WithColumn("end_time").AsTime().NotNullable()
			.WithColumn("day").AsCustom("day_of_week").NotNullable()
			.WithColumn("volunteer_id").AsInt32().NotNullable().ForeignKey("FK_VolunteerTime_Volunteer", "volunteer", "id")
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);

		// Create intermediate tables
		Create.Table("volunteer_skill")
			.WithColumn("volunteer_id").AsInt32().NotNullable().ForeignKey("FK_VolunteerSkill_Volunteer", "volunteer", "id").OnDelete(Rule.Cascade)
			.WithColumn("skill_id").AsInt32().NotNullable().ForeignKey("FK_VolunteerSkill_Skill", "skill", "id").OnDelete(Rule.Cascade)
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);
		Create.PrimaryKey("PK_VolunteerSkill").OnTable("volunteer_skill")
			.Columns(["volunteer_id", "skill_id"]);

		Create.Table("volunteer_task")
			.WithColumn("volunteer_id").AsInt32().NotNullable().ForeignKey("FK_VolunteerTask_Volunteer", "volunteer", "id").OnDelete(Rule.Cascade)
			.WithColumn("task_id").AsInt32().NotNullable().ForeignKey("FK_VolunteerTask_Task", "task", "id").OnDelete(Rule.Cascade)
			.WithColumn("state").AsCustom("state").NotNullable()
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);
		Create.PrimaryKey("PK_VolunteerTask").OnTable("volunteer_task")
			.Columns(["volunteer_id", "task_id"]);

		Create.Table("volunteer_place")
			.WithColumn("volunteer_id").AsInt32().NotNullable().ForeignKey("FK_VolunteerPlacePreference_Volunteer", "volunteer", "id").OnDelete(Rule.Cascade)
			.WithColumn("place_id").AsInt32().NotNullable().ForeignKey("FK_VolunteerPlacePreference_Place", "place", "id").OnDelete(Rule.Cascade)
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);
		Create.PrimaryKey("PK_VolunteerPlacePreference").OnTable("volunteer_place")
			.Columns(["volunteer_id", "place_id"]);

		Create.Table("task_skill")
			.WithColumn("task_id").AsInt32().NotNullable().ForeignKey("FK_TaskSkill_Task", "task", "id").OnDelete(Rule.Cascade)
			.WithColumn("skill_id").AsInt32().NotNullable().ForeignKey("FK_TaskSkill_Skill", "skill", "id").OnDelete(Rule.Cascade)
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);
		Create.PrimaryKey("PK_TaskSkill").OnTable("task_skill")
			.Columns(["task_id", "skill_id"]);

		Create.Table("task_donation")
			.WithColumn("task_id").AsInt32().NotNullable().ForeignKey("FK_TaskDonation_Task", "task", "id").OnDelete(Rule.Cascade)
			.WithColumn("donation_id").AsInt32().NotNullable().ForeignKey("FK_TaskDonation_PhysicalDonation", "physical_donation", "id").OnDelete(Rule.Cascade)
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);
		Create.PrimaryKey("PK_TaskDonation").OnTable("task_donation")
			.Columns(["task_id", "donation_id"]);

		Create.Table("route_location")
			.WithColumn("route_id").AsInt32().NotNullable().ForeignKey("FK_RouteLocation_Route", "route", "id").OnDelete(Rule.Cascade)
			.WithColumn("location_id").AsInt32().NotNullable().ForeignKey("FK_RouteLocation_Location", "location", "id").OnDelete(Rule.Cascade)
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);
		Create.PrimaryKey("PK_RouteLocation").OnTable("route_location")
			.Columns(["route_id", "location_id"]);

		Create.Table("place_affected_zone")
			.WithColumn("place_id").AsInt32().NotNullable().ForeignKey("FK_PlaceAffectedZone_Place", "place", "id").OnDelete(Rule.Cascade)
			.WithColumn("affected_zone_id").AsInt32().NotNullable().ForeignKey("FK_PlaceAffectedZone_AffectedZone", "affected_zone", "id").OnDelete(Rule.Cascade)
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);
		Create.PrimaryKey("PK_PlaceAffectedZone").OnTable("place_affected_zone")
			.Columns(["place_id", "affected_zone_id"]);

		Create.Table("need_task")
			.WithColumn("need_id").AsInt32().NotNullable().ForeignKey("FK_NeedTask_Need", "need", "id").OnDelete(Rule.Cascade)
			.WithColumn("task_id").AsInt32().NotNullable().ForeignKey("FK_NeedTask_Task", "task", "id").OnDelete(Rule.Cascade)
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);
		Create.PrimaryKey("PK_NeedTask").OnTable("need_task")
			.Columns(["need_id", "task_id"]);

		Create.Table("need_skill")
			.WithColumn("need_id").AsInt32().NotNullable().ForeignKey("FK_NeedSkill_Need", "need", "id").OnDelete(Rule.Cascade)
			.WithColumn("skill_id").AsInt32().NotNullable().ForeignKey("FK_NeedSkill_Skill", "skill", "id").OnDelete(Rule.Cascade)
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);
		Create.PrimaryKey("PK_NeedSkill").OnTable("need_skill")
			.Columns(["need_id", "skill_id"]);

		Create.Table("need_need_type")
			.WithColumn("need_id").AsInt32().NotNullable().ForeignKey("FK_NeedNeedType_Need", "need", "id").OnDelete(Rule.Cascade)
			.WithColumn("need_type_id").AsInt32().NotNullable().ForeignKey("FK_NeedNeedType_NeedType", "need_type", "id").OnDelete(Rule.Cascade)
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);
		Create.PrimaryKey("PK_NeedNeedType").OnTable("need_need_type")
			.Columns(["need_id", "need_type_id"]);

		Create.Table("affected_zone_location")
			.WithColumn("affected_zone_id").AsInt32().NotNullable().ForeignKey("FK_AffectedZoneLocation_AffectedZone", "affected_zone", "id").OnDelete(Rule.Cascade)
			.WithColumn("location_id").AsInt32().NotNullable().ForeignKey("FK_AffectedZoneLocation_Location", "location", "id").OnDelete(Rule.Cascade)
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);
		Create.PrimaryKey("PK_AffectedZoneLocation").OnTable("affected_zone_location")
			.Columns(["affected_zone_id", "location_id"]);

		Create.Table("notifications")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("name").AsString(255).NotNullable()
			.WithColumn("description").AsString(1000).NotNullable()
			.WithColumn("volunteer_id").AsInt32().Nullable().ForeignKey("FK_Notifications_Volunteer", "volunteer", "id").OnDelete(Rule.Cascade)
			.WithColumn("victim_id").AsInt32().Nullable().ForeignKey("FK_Notifications_Victim", "victim", "id").OnDelete(Rule.Cascade)
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);
		Execute.Sql(@"
			ALTER TABLE notifications ADD CONSTRAINT CK_Notifications_VolunteerOrVictim CHECK (
				(volunteer_id IS NOT NULL AND victim_id IS NULL) OR
				(volunteer_id IS NULL AND victim_id IS NOT NULL)
			);
		");
	}

	public override void Down() {
		// Delete foreign keys first (in order to avoid problems with restrictions)
		Delete.ForeignKey("FK_TaskTime_Task");
		Delete.ForeignKey("FK_VolunteerTime_Volunteer");
		Delete.ForeignKey("FK_RouteLocation_Location");
		Delete.ForeignKey("FK_RouteLocation_Route");
		Delete.ForeignKey("FK_Route_EndLocation");
		Delete.ForeignKey("FK_Route_StartLocation");
		Delete.ForeignKey("FK_VolunteerPlacePreference_Place");
		Delete.ForeignKey("FK_VolunteerPlacePreference_Volunteer");
		Delete.ForeignKey("FK_NeedTask_Task");
		Delete.ForeignKey("FK_NeedTask_Need");
		Delete.ForeignKey("FK_NeedSkill_Skill");
		Delete.ForeignKey("FK_NeedSkill_Need");
		Delete.ForeignKey("FK_Task_Location");
		Delete.ForeignKey("FK_PlaceAffectedZone_AffectedZone");
		Delete.ForeignKey("FK_PlaceAffectedZone_Place");
		Delete.ForeignKey("FK_AffectedZoneLocation_Location");
		Delete.ForeignKey("FK_AffectedZoneLocation_AffectedZone");
		Delete.ForeignKey("FK_NeedNeedType_NeedType");
		Delete.ForeignKey("FK_NeedNeedType_Need");
		Delete.ForeignKey("FK_NeedType_Admin");
		Delete.ForeignKey("FK_Place_Admin");
		Delete.ForeignKey("FK_Skill_Admin");
		Delete.ForeignKey("FK_Need_Admin");
		Delete.ForeignKey("FK_Task_Admin");
		Delete.ForeignKey("FK_MonetaryDonation_Admin");
		Delete.ForeignKey("FK_PhysicalDonation_Admin");
		Delete.ForeignKey("FK_Route_Admin");
		Delete.ForeignKey("FK_AffectedZone_Admin");
		Delete.ForeignKey("FK_MonetaryDonation_Volunteer");
		Delete.ForeignKey("FK_PhysicalDonation_Volunteer");
		Delete.ForeignKey("FK_TaskSkill_Skill");
		Delete.ForeignKey("FK_TaskSkill_Task");
		Delete.ForeignKey("FK_TaskDonation_PhysicalDonation");
		Delete.ForeignKey("FK_TaskDonation_Task");
		Delete.ForeignKey("FK_VolunteerTask_Task");
		Delete.ForeignKey("FK_VolunteerTask_Volunteer");
		Delete.ForeignKey("FK_VolunteerSkill_Skill");
		Delete.ForeignKey("FK_VolunteerSkill_Volunteer");
		Delete.ForeignKey("FK_Need_Victim");
		Delete.ForeignKey("FK_MonetaryDonation_Victim");
		Delete.ForeignKey("FK_PhysicalDonation_Victim");
		Delete.ForeignKey("FK_Volunteer_Location");
		Delete.ForeignKey("FK_Victim_Location");

		//Delete composed primary keys
		Delete.PrimaryKey("PK_NeedNeedType").FromTable("need_need_type");
		Delete.PrimaryKey("PK_NeedSkill").FromTable("need_skill");
		Delete.PrimaryKey("PK_NeedTask").FromTable("need_task");
		Delete.PrimaryKey("PK_TaskSkill").FromTable("task_skill");
		Delete.PrimaryKey("PK_RouteLocation").FromTable("route_location");
		Delete.PrimaryKey("PK_VolunteerSkill").FromTable("volunteer_skill");
		Delete.PrimaryKey("PK_VolunteerTask").FromTable("volunteer_task");
		Delete.PrimaryKey("PK_TaskDonation").FromTable("task_donation");
		Delete.PrimaryKey("PK_VolunteerPlacePreference").FromTable("volunteer_place");
		Delete.PrimaryKey("PK_AffectedZoneLocation").FromTable("affected_zone_location");
		Delete.PrimaryKey("PK_PlaceAffectedZone").FromTable("place_affected_zone");

		// Delete tables (in inverse order with respect to creation)
		Delete.Table("place_affected_zone");
		Delete.Table("affected_zone_location");
		Delete.Table("need_need_type");
		Delete.Table("need_skill");
		Delete.Table("need_task");
		Delete.Table("route_location");
		Delete.Table("task_donation");
		Delete.Table("task_skill");
		Delete.Table("volunteer_place");
		Delete.Table("volunteer_task");
		Delete.Table("volunteer_skill");
		Delete.Table("volunteer_time");
		Delete.Table("task_time");
		Delete.Table("route");
		Delete.Table("need_type");
		Delete.Table("need");
		Delete.Table("task");
		Delete.Table("skill");
		Delete.Table("place");
		Delete.Table("monetary_donation");
		Delete.Table("physical_donation");
		Delete.Table("affected_zone");
		Delete.Table("admin");
		Delete.Table("volunteer");
		Delete.Table("victim");
		Delete.Table("location");
		Delete.Table("notifications");

		// Delete types (enums) created (in inverse order with respect to creation)
		Execute.Sql("DROP TYPE IF EXISTS state CASCADE;");
		Execute.Sql("DROP TYPE IF EXISTS day_of_week CASCADE;");
		Execute.Sql("DROP TYPE IF EXISTS skill_level CASCADE;");
		Execute.Sql("DROP TYPE IF EXISTS transport_type CASCADE;");
		Execute.Sql("DROP TYPE IF EXISTS urgency_level CASCADE;");
		Execute.Sql("DROP TYPE IF EXISTS payment_service CASCADE;");
		Execute.Sql("DROP TYPE IF EXISTS payment_status CASCADE;");
		Execute.Sql("DROP TYPE IF EXISTS currency CASCADE;");
		Execute.Sql("DROP TYPE IF EXISTS item_type CASCADE;");
		Execute.Sql("DROP TYPE IF EXISTS hazard_level CASCADE;");

		// Delete schema
		Execute.Sql("DROP SCHEMA IF EXISTS public CASCADE;");
	}
}
