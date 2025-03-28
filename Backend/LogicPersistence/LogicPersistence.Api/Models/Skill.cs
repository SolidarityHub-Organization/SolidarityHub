namespace LogicPersistence.Api.Models;

public enum SkillLevel
{
    Beginner,
    Intermediate,
    Advanced
}

public class Skill
{
    public int id {get; set;}

    public string name {get; set;} 

    public SkillLevel level {get; set;}
}