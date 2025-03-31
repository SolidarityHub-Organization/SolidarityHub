namespace LogicPersistence.Api.Models;

// a victim can have several needs
public class VictimSkill {
	public int victim_id { get; set; }
	public int need_id { get; set; }
}