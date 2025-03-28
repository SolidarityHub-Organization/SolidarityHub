using FluentMigrator;

// When modifying the structure of the database, another file similar to this one must be created,
// the method Up() implements the modifications, and the method Down() deletes those modifications

[Migration(202503281)]
public class InitialMigration : Migration {
	public override void Up() {
		Execute.Sql("CREATE SCHEMA IF NOT EXISTS public;");

		Create.Table("victim")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("email").AsString(50).NotNullable()
			.WithColumn("password").AsString(50).NotNullable()
			.WithColumn("name").AsString(50).NotNullable()
			.WithColumn("surname").AsString(50).NotNullable()
			.WithColumn("prefix").AsInt32().NotNullable()
			.WithColumn("phone").AsInt32().NotNullable()
			.WithColumn("address").AsString(100).NotNullable()
			.WithColumn("dni").AsString(20).NotNullable();

		Create.Table("volunteer")
			.WithColumn("id").AsInt32().PrimaryKey().Identity()
			.WithColumn("email").AsString(50).NotNullable()
			.WithColumn("password").AsString(50).NotNullable()
			.WithColumn("name").AsString(50).NotNullable()
			.WithColumn("surname").AsString(50).NotNullable()
			.WithColumn("prefix").AsInt32().NotNullable()
			.WithColumn("phone").AsInt32().NotNullable()
			.WithColumn("address").AsString(100).NotNullable()
			.WithColumn("dni").AsString(20).NotNullable();

		Create.Table("admin")
			.WithColumn("jurisdiction").AsString(100).NotNullable();
	}

	public override void Down() {
		Delete.Table("victim");
		Delete.Table("volunteer");
		Delete.Table("admin");
		Execute.Sql("DROP SCHEMA IF EXISTS public CASCADE;");
	}
}
