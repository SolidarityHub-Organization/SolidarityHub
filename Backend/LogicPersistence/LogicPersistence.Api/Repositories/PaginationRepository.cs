namespace LogicPersistence.Api.Repositories;

using Dapper;
using Npgsql;

public class PaginationRepository : IPaginationRepository {
	private readonly string connectionString = DatabaseConfiguration.GetConnectionString();

    public async Task<(IEnumerable<T> Items, int TotalCount)> GetPaginatedAsync<T>(int pageNumber, int pageSize, string tableName, string orderBy = "created_at DESC, id DESC")
    {
        using var connection = new NpgsqlConnection(connectionString);

        string countSql = $"SELECT COUNT(*) FROM {tableName}";
        int totalCount = await connection.QuerySingleAsync<int>(countSql);

        string paginatedSql = $@"
            SELECT * FROM {tableName}
            ORDER BY {orderBy}
            OFFSET @Offset
            LIMIT @PageSize";

        int offset = (pageNumber - 1) * pageSize;
        var items = await connection.QueryAsync<T>(paginatedSql, new { Offset = offset, PageSize = pageSize });

        return (items, totalCount);
    }
}
