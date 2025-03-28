namespace LogicPersistence.Api.Models;

public class Victim {
	public int id { get; set; }
	public string email { get; set; } = string.Empty;
	public string password { get; set; } = string.Empty;
	public string name { get; set; } = string.Empty;
	public string surname { get; set; } = string.Empty;
	public int prefix { get; set; }
	public int phone_number { get; set; }
	public string address { get; set; } = string.Empty;
	public string victim_id { get; set; } = string.Empty;
}
