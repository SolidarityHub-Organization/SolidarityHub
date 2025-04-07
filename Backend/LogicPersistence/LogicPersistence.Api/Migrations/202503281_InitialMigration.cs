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
			.WithColumn("identification").AsString(20).NotNullable()
			.WithColumn("location_id").AsInt32().Nullable();

		Create.Table("volunteer")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("email").AsString(50).NotNullable()
			.WithColumn("password").AsString(128).NotNullable()
			.WithColumn("name").AsString(50).NotNullable()
			.WithColumn("surname").AsString(50).NotNullable()
			.WithColumn("prefix").AsInt32().NotNullable()
			.WithColumn("phone_number").AsInt64().NotNullable()
			.WithColumn("address").AsString(100).NotNullable()
			.WithColumn("identification").AsString(20).NotNullable()
			.WithColumn("location_id").AsInt32().Nullable();

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
			.WithColumn("hazard_level").AsCustom("hazard_level").NotNullable()
			.WithColumn("admin_id").AsInt32().NotNullable();

		Create.Table("donation")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("donation_date").AsDate().NotNullable()
			.WithColumn("volunteer_id").AsInt32().Nullable()
			.WithColumn("admin_id").AsInt32().Nullable()
			.WithColumn("victim_id").AsInt32().Nullable();

		Create.Table("physical_donation")
			.WithColumn("id").AsInt32().PrimaryKey().ForeignKey("FK_PhysicalDonation_Donation", "donation", "id")
			.WithColumn("item_name").AsString(50).NotNullable()
			.WithColumn("description").AsString(200).NotNullable()
			.WithColumn("quantity").AsInt32().NotNullable()
			.WithColumn("item_type").AsCustom("physical_donation_type").NotNullable();

		Create.Table("monetary_donation")
			.WithColumn("id").AsInt32().PrimaryKey().ForeignKey("FK_MonetaryDonation_Donation", "donation", "id")
			.WithColumn("amount").AsDecimal().NotNullable()
			.WithColumn("currency").AsCustom("currency").NotNullable()
			.WithColumn("payment_status").AsCustom("payment_status").NotNullable()
			.WithColumn("transaction_id").AsString(20).NotNullable()
			.WithColumn("payment_service").AsCustom("payment_service").NotNullable();

		Create.Table("location")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("latitude").AsDouble().NotNullable()
			.WithColumn("longitude").AsDouble().NotNullable()
			.WithColumn("volunteer_id").AsInt32().Nullable()
			.WithColumn("victim_id").AsInt32().Nullable();

		Create.Table("need")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("name").AsString(50).NotNullable()
			.WithColumn("description").AsString(200).NotNullable()
			.WithColumn("urgency_level").AsCustom("urgency_level").NotNullable()
			.WithColumn("admin_id").AsInt32().Nullable()
			.WithColumn("victim_id").AsInt32().Nullable();

		Create.Table("place")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("name").AsString(50).NotNullable()
			.WithColumn("admin_id").AsInt32().NotNullable();

		Create.Table("route")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("name").AsString(50).NotNullable()
			.WithColumn("description").AsString(200).NotNullable()
			.WithColumn("hazard_level").AsCustom("hazard_level").NotNullable()
			.WithColumn("transport_type").AsCustom("transport_type").NotNullable()
			.WithColumn("admin_id").AsInt32().Nullable()
			.WithColumn("start_location_id").AsInt32().NotNullable()
			.WithColumn("end_location_id").AsInt32().NotNullable();

		Create.Table("skill")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("name").AsString(50).NotNullable()
			.WithColumn("level").AsCustom("skill_level").NotNullable()
			.WithColumn("admin_id").AsInt32().NotNullable();

		Create.Table("task")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("name").AsString(50).NotNullable()
			.WithColumn("description").AsString(500).NotNullable()
			.WithColumn("admin_id").AsInt32().Nullable()
			.WithColumn("location_id").AsInt32().NotNullable();

		Create.Table("time")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("start_time").AsTime().NotNullable()
			.WithColumn("end_time").AsTime().NotNullable();
		
		Create.Table("need_type")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("name").AsString(50).NotNullable()
			.WithColumn("admin_id").AsInt32().NotNullable();

		Create.Table("need_need_type")
			.WithColumn("need_id").AsInt32().NotNullable()
			.WithColumn("need_type_id").AsInt32().NotNullable();

		// @carlos carloseando
		Create.Table("task_time")
			.WithColumn("id").AsInt32().PrimaryKey().ForeignKey("FK_TaskTime_Time", "time", "id")
			.WithColumn("date").AsDate().NotNullable()
			.WithColumn("task_id").AsInt32().NotNullable();
		

		Create.Table("volunteer_time")
			.WithColumn("id").AsInt32().PrimaryKey().ForeignKey("FK_VolunteerTime_Time", "time", "id")
			.WithColumn("day").AsCustom("day_of_week").NotNullable()
			.WithColumn("volunteer_id").AsInt32().NotNullable();

		Create.Table("route_location")
			.WithColumn("route_id").AsInt32().NotNullable()
			.WithColumn("location_id").AsInt32().NotNullable();
		Create.PrimaryKey("PK_RouteLocation").OnTable("route_location")
			.Columns(["route_id", "location_id"]);

		Create.Table("task_donation")
			.WithColumn("task_id").AsInt32().NotNullable()
			.WithColumn("donation_id").AsInt32().NotNullable();
		Create.PrimaryKey("PK_TaskDonation").OnTable("task_donation")
			.Columns(["task_id", "donation_id"]);

		Create.Table("volunteer_place_preference")
			.WithColumn("volunteer_id").AsInt32().NotNullable()
			.WithColumn("place_preference_id").AsInt32().NotNullable();
		Create.PrimaryKey("PK_VolunteerPlacePreference").OnTable("volunteer_place_preference")
			.Columns(["volunteer_id", "place_preference_id"]);

		Create.Table("task_skill")
			.WithColumn("task_id").AsInt32().NotNullable()
			.WithColumn("skill_id").AsInt32().NotNullable();
		Create.PrimaryKey("PK_TaskSkill").OnTable("task_skill")
			.Columns(["task_id", "skill_id"]);

		Create.Table("volunteer_skill")
			.WithColumn("volunteer_id").AsInt32().NotNullable()
			.WithColumn("skill_id").AsInt32().NotNullable();
		Create.PrimaryKey("PK_VolunteerSkill").OnTable("volunteer_skill")
			.Columns(["volunteer_id", "skill_id"]);

		Create.Table("volunteer_task")
			.WithColumn("volunteer_id").AsInt32().NotNullable()
			.WithColumn("task_id").AsInt32().NotNullable()
			.WithColumn("state").AsCustom("state").NotNullable();
		Create.PrimaryKey("PK_VolunteerTask").OnTable("volunteer_task")
			.Columns(["volunteer_id", "task_id"]);

		Create.Table("affected_zone_location")
			.WithColumn("location_id").AsInt32().NotNullable()
			.WithColumn("affected_zone_id").AsInt32().NotNullable();
		Create.PrimaryKey("PK_AffectedZoneLocation").OnTable("affected_zone_location")
			.Columns(["affected_zone_id", "location_id"]);

		Create.Table("need_skill")
			.WithColumn("need_id").AsInt32().NotNullable()
			.WithColumn("skill_id").AsInt32().NotNullable();
		Create.PrimaryKey("PK_NeedSkill").OnTable("need_skill")
			.Columns(["need_id", "skill_id"]);

		Create.Table("need_task")
			.WithColumn("need_id").AsInt32().NotNullable()
			.WithColumn("task_id").AsInt32().NotNullable();
		Create.PrimaryKey("PK_NeedTask").OnTable("need_task")
			.Columns(["need_id", "task_id"]);

		Create.Table("place_affected_zone")
			.WithColumn("place_id").AsInt32().NotNullable()
			.WithColumn("affected_zone_id").AsInt32().NotNullable();
		Create.PrimaryKey("PK_PlaceAffectedZone").OnTable("place_affected_zone")
			.Columns(["place_id", "affected_zone_id"]);

		// Create foreign key relations for the tables
		Create.ForeignKey("FK_Victim_Location")
			.FromTable("victim").ForeignColumn("location_id")
			.ToTable("location").PrimaryColumn("id");

		Create.ForeignKey("FK_Need_Victim")
			.FromTable("need").ForeignColumn("victim_id")
			.ToTable("victim").PrimaryColumn("id");

		Create.ForeignKey("FK_Donation_Victim")
			.FromTable("donation").ForeignColumn("victim_id")
			.ToTable("victim").PrimaryColumn("id");

		Create.ForeignKey("FK_Volunteer_Location")
			.FromTable("volunteer").ForeignColumn("location_id")
			.ToTable("location").PrimaryColumn("id");

		Create.ForeignKey("FK_VolunteerSkill_Volunteer")
			.FromTable("volunteer_skill").ForeignColumn("volunteer_id")
			.ToTable("volunteer").PrimaryColumn("id");

		Create.ForeignKey("FK_VolunteerSkill_Skill")
			.FromTable("volunteer_skill").ForeignColumn("skill_id")
			.ToTable("skill").PrimaryColumn("id");

		Create.ForeignKey("FK_VolunteerTask_Volunteer")
			.FromTable("volunteer_task").ForeignColumn("volunteer_id")
			.ToTable("volunteer").PrimaryColumn("id");

		Create.ForeignKey("FK_VolunteerTask_Task")
			.FromTable("volunteer_task").ForeignColumn("task_id")
			.ToTable("task").PrimaryColumn("id");

		Create.ForeignKey("FK_Donation_Volunteer")
			.FromTable("donation").ForeignColumn("volunteer_id")
			.ToTable("volunteer").PrimaryColumn("id");

		Create.ForeignKey("FK_AffectedZone_Admin")
			.FromTable("affected_zone").ForeignColumn("admin_id")
			.ToTable("admin").PrimaryColumn("id");

		Create.ForeignKey("FK_Route_Admin")
			.FromTable("route").ForeignColumn("admin_id")
			.ToTable("admin").PrimaryColumn("id");

		Create.ForeignKey("FK_Donation_Admin")
			.FromTable("donation").ForeignColumn("admin_id")
			.ToTable("admin").PrimaryColumn("id");

		Create.ForeignKey("FK_Task_Admin")
			.FromTable("task").ForeignColumn("admin_id")
			.ToTable("admin").PrimaryColumn("id");

		Create.ForeignKey("FK_Need_Admin")
			.FromTable("need").ForeignColumn("admin_id")
			.ToTable("admin").PrimaryColumn("id");

		Create.ForeignKey("FK_Skill_Admin")
			.FromTable("skill").ForeignColumn("admin_id")
			.ToTable("admin").PrimaryColumn("id");

		Create.ForeignKey("FK_Place_Admin")
			.FromTable("place").ForeignColumn("admin_id")
			.ToTable("admin").PrimaryColumn("id");

		Create.ForeignKey("FK_AffectedZoneLocation_AffectedZone")
			.FromTable("affected_zone_location").ForeignColumn("affected_zone_id")
			.ToTable("affected_zone").PrimaryColumn("id");

		Create.ForeignKey("FK_AffectedZoneLocation_Location")
			.FromTable("affected_zone_location").ForeignColumn("location_id")
			.ToTable("location").PrimaryColumn("id");

		Create.ForeignKey("FK_PlaceAffectedZone_Place")
			.FromTable("place_affected_zone").ForeignColumn("place_id")
			.ToTable("place").PrimaryColumn("id");

		Create.ForeignKey("FK_PlaceAffectedZone_AffectedZone")
			.FromTable("place_affected_zone").ForeignColumn("affected_zone_id")
			.ToTable("affected_zone").PrimaryColumn("id");

		Create.ForeignKey("FK_TaskDonation_Task")
			.FromTable("task_donation").ForeignColumn("task_id")
			.ToTable("task").PrimaryColumn("id");

		Create.ForeignKey("FK_TaskDonation_Donation")
			.FromTable("task_donation").ForeignColumn("donation_id")
			.ToTable("donation").PrimaryColumn("id");

		Create.ForeignKey("FK_Task_Location")
			.FromTable("task").ForeignColumn("location_id")
			.ToTable("location").PrimaryColumn("id");

		Create.ForeignKey("FK_Location_Victim")
			.FromTable("location").ForeignColumn("victim_id")
			.ToTable("victim").PrimaryColumn("id");

		Create.ForeignKey("FK_Location_Volunteer")
			.FromTable("location").ForeignColumn("volunteer_id")
			.ToTable("volunteer").PrimaryColumn("id");

		Create.ForeignKey("FK_NeedSkill_Need")
			.FromTable("need_skill").ForeignColumn("need_id")
			.ToTable("need").PrimaryColumn("id");

		Create.ForeignKey("FK_NeedSkill_Skill")
			.FromTable("need_skill").ForeignColumn("skill_id")
			.ToTable("skill").PrimaryColumn("id");

		Create.ForeignKey("FK_NeedTask_Need")
			.FromTable("need_task").ForeignColumn("need_id")
			.ToTable("need").PrimaryColumn("id");

		Create.ForeignKey("FK_NeedTask_Task")
			.FromTable("need_task").ForeignColumn("task_id")
			.ToTable("task").PrimaryColumn("id");

		Create.ForeignKey("FK_VolunteerPlacePreference_Volunteer")
			.FromTable("volunteer_place_preference").ForeignColumn("volunteer_id")
			.ToTable("volunteer").PrimaryColumn("id");

		Create.ForeignKey("FK_VolunteerPlacePreference_Place")
			.FromTable("volunteer_place_preference").ForeignColumn("place_preference_id")
			.ToTable("place").PrimaryColumn("id");

		Create.ForeignKey("FK_Route_StartLocation")
			.FromTable("route").ForeignColumn("start_location_id")
			.ToTable("location").PrimaryColumn("id");

		Create.ForeignKey("FK_Route_EndLocation")
			.FromTable("route").ForeignColumn("end_location_id")
			.ToTable("location").PrimaryColumn("id");

		Create.ForeignKey("FK_RouteLocation_Route")
			.FromTable("route_location").ForeignColumn("route_id")
			.ToTable("route").PrimaryColumn("id");

		Create.ForeignKey("FK_RouteLocation_Location")
			.FromTable("route_location").ForeignColumn("location_id")
			.ToTable("location").PrimaryColumn("id");

		Create.ForeignKey("FK_TaskTime_Task")
			.FromTable("task_time").ForeignColumn("task_id")
			.ToTable("task").PrimaryColumn("id");

		Create.ForeignKey("FK_VolunteerTime_Volunteer")
			.FromTable("volunteer_time").ForeignColumn("volunteer_id")
			.ToTable("volunteer").PrimaryColumn("id");
	}

	public override void Down() {
		// Delete foreign keys first (in order to avoid problems with restrictions)
		Delete.ForeignKey("FK_TaskTime_Task");
		Delete.ForeignKey("FK_VolunteerTime_Volunteer");
		Delete.ForeignKey("FK_TaskTime_Time");
		Delete.ForeignKey("FK_VolunteerTime_Time");
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
		Delete.ForeignKey("FK_Location_Volunteer");
		Delete.ForeignKey("FK_Location_Victim");
		Delete.ForeignKey("FK_Task_Location");
		Delete.ForeignKey("FK_PlaceAffectedZone_AffectedZone");
		Delete.ForeignKey("FK_PlaceAffectedZone_Place");
		Delete.ForeignKey("FK_AffectedZoneLocation_Location");
		Delete.ForeignKey("FK_AffectedZoneLocation_AffectedZone");
		Delete.ForeignKey("FK_Place_Admin");
		Delete.ForeignKey("FK_Skill_Admin");
		Delete.ForeignKey("FK_Need_Admin");
		Delete.ForeignKey("FK_Task_Admin");
		Delete.ForeignKey("FK_Donation_Admin");
		Delete.ForeignKey("FK_Route_Admin");
		Delete.ForeignKey("FK_AffectedZone_Admin");
		Delete.ForeignKey("FK_Donation_Volunteer");
		Delete.ForeignKey("FK_VolunteerTask_Task");
		Delete.ForeignKey("FK_VolunteerTask_Volunteer");
		Delete.ForeignKey("FK_VolunteerSkill_Skill");
		Delete.ForeignKey("FK_VolunteerSkill_Volunteer");
		Delete.ForeignKey("FK_VolunteerTime_Volunteer");
		Delete.ForeignKey("FK_Volunteer_Location");
		Delete.ForeignKey("FK_Donation_Victim");
		Delete.ForeignKey("FK_Need_Victim");
		Delete.ForeignKey("FK_Victim_Location");
		Delete.ForeignKey("FK_PhysicalDonation_Donation");
		Delete.ForeignKey("FK_MonetaryDonation_Donation");

		//Delete composed primary keys
		Delete.PrimaryKey("PK_TaskTime").FromTable("task_time");
		Delete.PrimaryKey("PK_VolunteerTime").FromTable("volunteer_time");
		Delete.PrimaryKey("PK_NeedSkill").FromTable("need_skill");
		Delete.PrimaryKey("PK_NeedTask").FromTable("need_task");
		Delete.PrimaryKey("PK_TaskSkill").FromTable("task_skill");
		Delete.PrimaryKey("PK_RouteLocation").FromTable("route_location");
		Delete.PrimaryKey("PK_VolunteerSkill").FromTable("volunteer_skill");
		Delete.PrimaryKey("PK_VolunteerTask").FromTable("volunteer_task");
		Delete.PrimaryKey("PK_TaskDonation").FromTable("task_donation");
		Delete.PrimaryKey("PK_VolunteerPlacePreference").FromTable("volunteer_place_preference");
		Delete.PrimaryKey("PK_AffectedZoneLocation").FromTable("affected_zone_location");
		Delete.PrimaryKey("PK_PlaceAffectedZone").FromTable("place_affected_zone");

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
		Delete.Table("task_time");
		Delete.Table("volunteer_time");
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
