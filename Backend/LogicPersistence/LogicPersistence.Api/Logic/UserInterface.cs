using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Services;

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

		public Task<IUser> Save(ISignupServices _SignupServices);
    }

    public static class UserFactory
    {
        public static IUser CreateUser(SignupDto user)
        {
            return user.role switch
            {
                "Victim" => new Victim
                {
                    email = user.email,
                    password = user.password,
                    name = user.name,
                    surname = user.surname,
                    prefix = user.prefix,
                    phone_number = user.phone_number,
                    address = user.address,
                    identification = user.identification,
                    location_id = user.location_id
                },
                "Volunteer" => new Volunteer
                {
                    email = user.email,
                    password = user.password,
                    name = user.name,
                    surname = user.surname,
                    prefix = user.prefix,
                    phone_number = user.phone_number,
                    address = user.address,
                    identification = user.identification,
                    location_id = user.location_id
                },
                _ => throw new ArgumentException("Invalid role type", nameof(user.role))
            };
        }
    }
}
