namespace LogicPersistence.Api.Services.ObserverPattern;

public interface ITaskAssignmentObserver {
    void OnTaskAssigned(int volunteerId, int taskId, string taskName);
}
