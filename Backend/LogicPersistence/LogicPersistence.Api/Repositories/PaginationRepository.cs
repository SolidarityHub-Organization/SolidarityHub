namespace LogicPersistence.Api.Repositories;

using Dapper;
using Npgsql;

public class PaginationRepository : IPaginationRepository {
	private readonly string connectionString = DatabaseConfiguration.Instance.GetConnectionString();

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

    public async Task<(IEnumerable<T> Items, int TotalCount)> GetPaginatedByDateRangeAsync<T>(
        int pageNumber, 
        int pageSize, 
        string tableName,
        DateTime fromDate,
        DateTime toDate, 
        string orderBy = "created_at DESC, id DESC",
        string dateColumnName = "created_at")
    {
        using var connection = new NpgsqlConnection(connectionString);

        string countSql = $"SELECT COUNT(*) FROM {tableName} WHERE {dateColumnName} >= @FromDate AND {dateColumnName} <= @ToDate";
        int totalCount = await connection.QuerySingleAsync<int>(countSql, new { FromDate = fromDate, ToDate = toDate });

        string paginatedSql = $@"
            SELECT * FROM {tableName}
            WHERE {dateColumnName} >= @FromDate AND {dateColumnName} <= @ToDate
            ORDER BY {orderBy}
            OFFSET @Offset
            LIMIT @PageSize";

        int offset = (pageNumber - 1) * pageSize;
        var items = await connection.QueryAsync<T>(
            paginatedSql, 
            new { 
                Offset = offset, 
                PageSize = pageSize, 
                FromDate = fromDate, 
                ToDate = toDate 
            }
        );

        return (Items: items, TotalCount: totalCount);
    }
}
