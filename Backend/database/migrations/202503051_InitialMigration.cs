using FluentMigrator;

[Migration(202503051)]
public class InitialMigration : Migration
{
    public override void Up()
    {
        Execute.Sql("CREATE SCHEMA IF NOT EXISTS public;");

        Create.Table("Users")
            .WithColumn("Id").AsInt32().PrimaryKey().Identity()
            .WithColumn("Name").AsString(100).NotNullable()
            .WithColumn("Test").AsInt32().NotNullable()
            .WithColumn("CreatedAt").AsDateTimeOffset().NotNullable().WithDefault(SystemMethods.CurrentDateTime)
            .WithColumn("UpdatedAt").AsDateTimeOffset().NotNullable().WithDefault(SystemMethods.CurrentDateTime);

        Create.Index("idx_users_name")
            .OnTable("Users")
            .OnColumn("Name");
    }

    public override void Down()
    {
        Delete.Table("Users");
        Execute.Sql("DROP SCHEMA IF EXISTS public CASCADE;");
    }
}