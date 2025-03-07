using FluentMigrator;

[Migration(202503052)]
public class AddUserEmailColumn : Migration
{
    public override void Up()
    {
        Alter.Table("Users")
            .AddColumn("Email").AsString(255).Nullable();
    }

    public override void Down()
    {
        Delete.Column("Email").FromTable("Users");
    }
}