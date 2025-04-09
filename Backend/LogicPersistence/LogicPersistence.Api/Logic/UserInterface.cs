namespace LogicPersistence.Api.Logic
{
    public interface IUser
    {
        int Id { get; set; }
        string Name { get; set; }
        string Email { get; set; }
        string Role { get; set; } // e.g., "Victim" or "Volunteer"
    }
}