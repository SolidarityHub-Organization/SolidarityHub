namespace LogicPersistence.Api.Logic
{
    public interface IUser
    {
        public int id { get; set; }
	    public string email { get; set; }
	    public string password { get; set; }
	    public string name { get; set; }
    	public string surname { get; set; }
	    public int prefix { get; set; }
	    public int phone_number { get; set; }
	    public string address { get; set; }
        public string identification { get; set; }
        public int? location_id { get; set; }
    }

    public static class UserFactory
    {
        public static IUser CreateUser(string role, int id, string name, string email)
        {
            return role switch
            {
                "Victim" => new VictimUser { Id = id, Name = name, Email = email },
                "Volunteer" => new VolunteerUser { Id = id, Name = name, Email = email },
                _ => throw new ArgumentException("Invalid role type", nameof(role))
            };
        }
    }
}