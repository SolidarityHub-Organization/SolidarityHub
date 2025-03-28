using FluentMigrator;

[Migration(202503281)]
public class InitialMigration : Migration
{
    public override void Up()
    {
        Execute.Sql("CREATE SCHEMA IF NOT EXISTS public;");

        Execute.Sql("CREATE TYPE user_type_enum AS ENUM ('volunteer', 'victim');");

        Create.Table("user")
            .WithColumn("id").AsInt32().PrimaryKey().Identity()
            .WithColumn("email").AsString(50).NotNullable()
            .WithColumn("password").AsString(50).NotNullable();

        Create.Table("person")
            .WithColumn("name").AsString(50).NotNullable()
            .WithColumn("surname").AsString(50).NotNullable()
            .WithColumn("prefix").AsInt32().NotNullable()
            .WithColumn("phone").AsInt32().NotNullable()
            .WithColumn("user_type").AsCustom("user_type_enum").NotNullable()
            .WithColumn("address").AsString(100).NotNullable()
            .WithColumn("dni").AsString(20).NotNullable();

        Create.Table("admin")
            .WithColumn("jurisdiction").AsString(100).NotNullable();
    }

    public override void Down()
    {
        Delete.Table("user");
        Delete.Table("person");
        Execute.Sql("DROP TYPE IF EXISTS user_type_enum;");
        Execute.Sql("DROP SCHEMA IF EXISTS public CASCADE;");
    }
}