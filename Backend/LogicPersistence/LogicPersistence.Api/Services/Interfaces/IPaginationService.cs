namespace LogicPersistence.Api.Services.Interfaces;

public interface IPaginationService {
    Task<(IEnumerable<T> Items, int TotalCount)> GetPaginatedAsync<T>(
        int pageNumber,
        int pageSize,
        string tableName,
        string orderBy = "created_at DESC, id DESC");
    Task<(IEnumerable<T> Items, int TotalCount)> GetPaginatedByDateRangeAsync<T>(
        int pageNumber,
        int pageSize,
        string tableName,
        DateTime fromDate,
        DateTime toDate,
        string orderBy = "created_at DESC, id DESC",
        string dateColumnName = "created_at");
}
