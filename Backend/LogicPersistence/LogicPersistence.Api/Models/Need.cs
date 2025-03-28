namespace LogicPersistence.Api.Models;

public enum UrgencyLevel {
	Bajo = 0,
	Medio = 1,
	Alto = 2,
	Critico = 3
}

public class Need {
	public int id { get; set; }

	public required string name { get; set; }

	public required string description { get; set; }

	public UrgencyLevel urgencyLevel { get; set; }
}
