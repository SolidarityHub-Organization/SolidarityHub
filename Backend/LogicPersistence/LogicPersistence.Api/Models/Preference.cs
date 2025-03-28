using System.Collections.Generic;

namespace LogicPersistence.Api.Models;

public class Preference
{
    public int id {get; set;}
    public string name {get; set;} = string.Empty;
    public List<Person> people { get; set; } = new List<Person>();
}