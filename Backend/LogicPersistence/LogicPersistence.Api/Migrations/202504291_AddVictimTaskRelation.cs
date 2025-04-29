using FluentMigrator;
using System.Data;

[Migration(202504291)]
public class AddVictimTaskRelation : Migration {
	public override void Up() {
		Create.Table("victim_task")
			.WithColumn("victim_id").AsInt32().NotNullable().ForeignKey("FK_VictimTask_Victim", "victim", "id").OnDelete(Rule.Cascade)
			.WithColumn("task_id").AsInt32().NotNullable().ForeignKey("FK_VictimTask_Task", "task", "id").OnDelete(Rule.Cascade)
			.WithColumn("state").AsCustom("state").NotNullable()
			.WithColumn("created_at").AsDateTime().WithDefaultValue(SystemMethods.CurrentDateTime);

		Create.PrimaryKey("PK_VictimTask").OnTable("victim_task")
			.Columns(["victim_id", "task_id"]);
	}

	public override void Down() {
		Delete.PrimaryKey("PK_VictimTask").FromTable("victim_task");
		Delete.Table("victim_task");
	}
}
