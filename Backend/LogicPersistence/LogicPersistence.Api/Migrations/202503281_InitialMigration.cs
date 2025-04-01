using FluentMigrator;

// When modifying the structure of the database, another file similar to this one must be created,
// the method Up() implements the modifications, and the method Down() deletes those modifications

[Migration(202503281)]
public class InitialMigration : Migration {
	public override void Up() {
		Execute.Sql("CREATE SCHEMA IF NOT EXISTS public;");

		Execute.Sql("CREATE TYPE IF NOT EXISTS hazard_level AS ENUM('unknown', 'low', 'medium', 'high', 'critical')");
		Execute.Sql("CREATE TYPE IF NOT EXISTS physical_donation_type AS ENUM('other', 'food', 'tools', 'clothes', 'medicine', 'furniture')");
		Execute.Sql("CREATE TYPE IF NOT EXISTS currency AS ENUM('other', 'usd', 'eur')");
		Execute.Sql("CREATE TYPE IF NOT EXISTS payment_status AS ENUM('pending', 'completed', 'failed', 'refunded')");
		Execute.Sql("CREATE TYPE IF NOT EXISTS payment_service AS ENUM('paypal', 'bank_transfer', 'credit_card', 'other')");

		Create.Table("victim")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("email").AsString(50).NotNullable()
			.WithColumn("password").AsString(50).NotNullable()
			.WithColumn("name").AsString(50).NotNullable()
			.WithColumn("surname").AsString(50).NotNullable()
			.WithColumn("prefix").AsInt32().NotNullable()
			.WithColumn("phone_number").AsInt32().NotNullable()
			.WithColumn("address").AsString(100).NotNullable()
			.WithColumn("identification").AsString(20).NotNullable();

		Create.Table("volunteer")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("email").AsString(50).NotNullable()
			.WithColumn("password").AsString(50).NotNullable()
			.WithColumn("name").AsString(50).NotNullable()
			.WithColumn("surname").AsString(50).NotNullable()
			.WithColumn("prefix").AsInt32().NotNullable()
			.WithColumn("phone_number").AsInt32().NotNullable()
			.WithColumn("address").AsString(100).NotNullable()
			.WithColumn("identification").AsString(20).NotNullable();

		Create.Table("admin")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("jurisdiction").AsString(100).NotNullable()
			.WithColumn("email").AsString(50).NotNullable()
			.WithColumn("password").AsString(50).NotNullable()
			.WithColumn("name").AsString(50).NotNullable()
			.WithColumn("surname").AsString(50).NotNullable()
			.WithColumn("prefix").AsInt32().NotNullable()
			.WithColumn("phone_number").AsInt32().NotNullable()
			.WithColumn("address").AsString(100).NotNullable()
			.WithColumn("identification").AsString(20).NotNullable();

		Create.Table("affected_zone")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("name").AsString(50).NotNullable()
			.WithColumn("description").AsString(3000).NotNullable()
			.WithColumn("hazard_level").AsCustom("hazard_level").NotNullable().WithDefaultValue("unknown");

		Create.Table("donation")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("donation_date").AsDateTime().NotNullable();

		Create.Table("physical_donation")
			.WithColumn("item_name").AsString(50).NotNullable()
			.WithColumn("description").AsString(3000).NotNullable()
			.WithColumn("quantity").AsInt32().NotNullable()
			.WithColumn("physical_donation_type").AsCustom("physical_donation_type").NotNullable().WithDefaultValue("other");

		Create.Table("monetary_donation")
			.WithColumn("amount").AsInt32().NotNullable()
			.WithColumn("item_name").AsString(50).NotNullable()
			.WithColumn("description").AsString(3000).NotNullable()
			.WithColumn("quantity").AsInt16().NotNullable()
			.WithColumn("physical_donation_type").AsCustom("physical_donation_type").NotNullable().WithDefaultValue("other");

		/* Foreign Key Example
		Create.ForeignKey("FK_HelpRequest_Victim")
        	.FromTable("help_request").ForeignColumn("victim_id")
        	.ToTable("victim").PrimaryColumn("id");*/
	}

	public override void Down() {
		Delete.Table("victim");
		Delete.Table("volunteer");
		Delete.Table("admin");
		Execute.Sql("DROP SCHEMA IF EXISTS public CASCADE;");
	}
}
