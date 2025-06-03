namespace LogicPersistence.Api.Repositories;

public interface IPaginationRepository {
	public Task<(IEnumerable<T> Items, int TotalCount)> GetPaginatedAsync<T>(
		int pageNumber,
		int pageSize,
		string tableName,
		string orderBy = "created_at DESC, id DESC");
	public Task<(IEnumerable<T> Items, int TotalCount)> GetPaginatedByDateRangeAsync<T>(
		int pageNumber,
		int pageSize,
		string tableName,
		DateTime fromDate,
		DateTime toDate,
		string orderBy = "created_at DESC, id DESC",
		string dateColumnName = "created_at");
	public Task<(IEnumerable<T> Items, int TotalCount)> GetPaginatedRelatedEntitiesAsync<T>(
        int pageNumber,
        int pageSize,
        string intermediateTable,
        string sourceColumn,
        int sourceId,
        string targetTable,
        string targetColumn,
        string orderBy = "id DESC");
	public Task<(IEnumerable<T> Items, int TotalCount)> GetPaginatedRelatedEntitiesByDateRangeAsync<T>(
		int pageNumber,
		int pageSize,
		string intermediateTable,
		string sourceColumn,
		int sourceId,
		string targetTable,
		string targetColumn,
		DateTime fromDate,
		DateTime toDate,
		string dateColumnName = "created_at",
		string orderBy = "id DESC");
}
