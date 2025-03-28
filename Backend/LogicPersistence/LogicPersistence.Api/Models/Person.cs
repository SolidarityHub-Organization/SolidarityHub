using System;

namespace LogicPersistence.Api.Models;

public class Person : User
{
    public string name { get; set; } = string.Empty;
}