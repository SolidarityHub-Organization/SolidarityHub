using LogicPersistence.Api.Models;

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
        public static IUser CreateUser(string role, int id, string email, string password, string name, string surname, int prefix, int phoneNumber, string address, string identification, int? locationId)
        {
            return role switch
            {
                "Victim" => new Victim
                {
                    id = id,
                    email = email,
                    password = password,
                    name = name,
                    surname = surname,
                    prefix = prefix,
                    phone_number = phoneNumber,
                    address = address,
                    identification = identification,
                    location_id = locationId
                },
                "Volunteer" => new Volunteer
                {
                    id = id,
                    email = email,
                    password = password,
                    name = name,
                    surname = surname,
                    prefix = prefix,
                    phone_number = phoneNumber,
                    address = address,
                    identification = identification,
                    location_id = locationId
                },
                _ => throw new ArgumentException("Invalid role type", nameof(role))
            };
        }
    }
}