/// Represents the possible statuses of a task.
public enum TaskStatus: Sendable {
    
    /// The task is queued and waiting to be executed.
    case queued
    
    /// The task is currently being executed.
    case inProgress
    
    /// The task has completed execution successfully.
    case finished
    
    /// The task has been canceled before completion.
    case canceled
}
