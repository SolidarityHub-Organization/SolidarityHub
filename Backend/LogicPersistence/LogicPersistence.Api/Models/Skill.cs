namespace LogicPersistence.Api.Models;

public enum SkillLevel {
	Principiante = 0,
	Intermedio = 1,
	Avanzado = 2
}

public class Skill {
	public int id { get; set; }

	public required string name { get; set; }

	public SkillLevel level { get; set; }
}
