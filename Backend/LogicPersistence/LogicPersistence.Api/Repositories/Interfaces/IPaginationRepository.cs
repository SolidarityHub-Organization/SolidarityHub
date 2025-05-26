namespace LogicPersistence.Api.Repositories;

public interface IPaginationRepository {
	public Task<(IEnumerable<T> Items, int TotalCount)> GetPaginatedAsync<T>(int pageNumber, int pageSize, string tableName, string orderBy = "created_at DESC, id DESC");
}
