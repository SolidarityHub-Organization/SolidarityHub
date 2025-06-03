using System.ComponentModel.DataAnnotations;
using Dapper;
using System.Data;

namespace LogicPersistence.Api.Models;

public enum State {
	[Display(Name = "Desconocido")]
	Unknown = -1,
	[Display(Name = "Asignado")]
	Assigned = 0,
	[Display(Name = "Pendiente")]
	Pending = 1,
	[Display(Name = "Completado")]
	Completed = 2,
	[Display(Name = "Cancelado")]
	Cancelled = 3
}

// volunteers can sign up for tasks
public class VolunteerTask {
	public int volunteer_id { get; set; }
	public int task_id { get; set; }
	public State state { get; set; }
}

//TODO: move this and all type handlers to type handlers folder
public class StateTypeHandler : SqlMapper.TypeHandler<State>
{
    public override State Parse(object value)
    {
        return value switch
        {
            string str => Enum.Parse<State>(str),
            int i => (State)i,
            _ => State.Unknown
        };
    }

    public override void SetValue(IDbDataParameter parameter, State value)
    {
        parameter.Value = value.ToString();
    }
}