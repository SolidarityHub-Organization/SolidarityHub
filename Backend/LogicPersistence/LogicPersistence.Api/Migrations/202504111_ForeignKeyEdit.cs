using FluentMigrator;
using System.Data;

[Migration(202504111)]
public class AddCascadeDeleteToTimeRelations : Migration {
	public override void Up() {
		Delete.ForeignKey("FK_TaskTime_Task").OnTable("task_time");
		Delete.ForeignKey("FK_VolunteerTime_Volunteer").OnTable("volunteer_time");

		Create.ForeignKey("FK_TaskTime_Task")
			.FromTable("task_time").ForeignColumn("task_id")
			.ToTable("task").PrimaryColumn("id")
			.OnDelete(Rule.Cascade);

		Create.ForeignKey("FK_VolunteerTime_Volunteer")
			.FromTable("volunteer_time").ForeignColumn("volunteer_id")
			.ToTable("volunteer").PrimaryColumn("id")
			.OnDelete(Rule.Cascade);
	}

	public override void Down() {
		Delete.ForeignKey("FK_TaskTime_Task").OnTable("task_time");
		Delete.ForeignKey("FK_VolunteerTime_Volunteer").OnTable("volunteer_time");

		Create.ForeignKey("FK_TaskTime_Task")
			.FromTable("task_time").ForeignColumn("task_id")
			.ToTable("task").PrimaryColumn("id");

		Create.ForeignKey("FK_VolunteerTime_Volunteer")
			.FromTable("volunteer_time").ForeignColumn("volunteer_id")
			.ToTable("volunteer").PrimaryColumn("id");
	}
}
