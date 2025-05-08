using System.Data;
using FluentMigrator;

[Migration(202503282)]
public class AddPointTables : Migration
{
    public override void Up()
    {
        Create.Table("point_time")
            .WithColumn("id").AsInt32().PrimaryKey().Identity()
            .WithColumn("start_time").AsTime().NotNullable()
            .WithColumn("end_time").AsTime().NotNullable()
            .WithColumn("start_date").AsDate().NotNullable()
            .WithColumn("end_date").AsDate().Nullable()
            .WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);

        Create.Table("pickup_point")
            .WithColumn("id").AsInt32().PrimaryKey().Identity()
            .WithColumn("name").AsString(255).NotNullable()
            .WithColumn("description").AsString(1000).NotNullable()
            .WithColumn("time_id").AsInt32().NotNullable().ForeignKey("FK_PickupPoint_PointTime", "point_time", "id")
            .WithColumn("location_id").AsInt32().NotNullable().ForeignKey("FK_PickupPoint_Location", "location", "id")
            .WithColumn("admin_id").AsInt32().Nullable().ForeignKey("FK_PickupPoint_Admin", "admin", "id")
            .WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);

        Create.Table("meeting_point")
            .WithColumn("id").AsInt32().PrimaryKey().Identity()
            .WithColumn("name").AsString(255).NotNullable()
            .WithColumn("description").AsString(1000).NotNullable()
            .WithColumn("time_id").AsInt32().NotNullable().ForeignKey("FK_MeetingPoint_PointTime", "point_time", "id")
            .WithColumn("location_id").AsInt32().NotNullable().ForeignKey("FK_MeetingPoint_Location", "location", "id")
            .WithColumn("admin_id").AsInt32().Nullable().ForeignKey("FK_MeetingPoint_Admin", "admin", "id")
            .WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);


        Create.Table("point_donation")
            .WithColumn("point_id").AsInt32().NotNullable().ForeignKey("FK_PointDonation_PickupPoint", "pickup_point", "id").OnDelete(Rule.Cascade)
            .WithColumn("donation_id").AsInt32().NotNullable().ForeignKey("FK_PointDonation_PhysicalDonation", "physical_donation", "id").OnDelete(Rule.Cascade)
            .WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);
        Create.PrimaryKey("PK_PointDonation").OnTable("point_donation")
            .Columns(["point_id", "donation_id"]);
    }

    public override void Down()
    {
        Delete.ForeignKey("FK_PointDonation_PickupPoint");
        Delete.ForeignKey("FK_PointDonation_PhysicalDonation");
        Delete.ForeignKey("FK_MeetingPoint_PointTime");
        Delete.ForeignKey("FK_MeetingPoint_Location");
        Delete.ForeignKey("FK_MeetingPoint_Admin");
        Delete.ForeignKey("FK_PickupPoint_PointTime");
        Delete.ForeignKey("FK_PickupPoint_Location");
        Delete.ForeignKey("FK_PickupPoint_Admin");
        
        Delete.PrimaryKey("PK_PointDonation").FromTable("point_donation");

        Delete.Table("point_donation");
        Delete.Table("meeting_point");
        Delete.Table("pickup_point");
        Delete.Table("point_time");
    }
}