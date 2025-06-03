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
            SELECT *
            FROM {tableName}
            ORDER BY {orderBy}
            OFFSET @Offset
            LIMIT @PageSize";

        int offset = (pageNumber - 1) * pageSize;
        var items = await connection.QueryAsync<T>(paginatedSql, new { Offset = offset, PageSize = pageSize });

        return (Items: items, TotalCount: totalCount);
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
            SELECT *
            FROM {tableName}
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

    public async Task<(IEnumerable<T> Items, int TotalCount)> GetPaginatedRelatedEntitiesAsync<T>(
        int pageNumber,
        int pageSize,
        string intermediateTable,
        string sourceColumn,   // ex. "task_id"
        int sourceId,          // ex. the task id
        string targetTable,    // ex. "volunteer"
        string targetColumn,   // ex. "volunteer_id"
        string orderBy = "id DESC")
    {
        using var connection = new NpgsqlConnection(connectionString);

        string countSql = $"SELECT COUNT(*) FROM {intermediateTable} WHERE {sourceColumn} = @sourceId";
        int totalCount = await connection.ExecuteScalarAsync<int>(countSql, new { sourceId });

        string sql = $@"
            SELECT t.*
            FROM {intermediateTable} it
            JOIN {targetTable} t ON it.{targetColumn} = t.id
            WHERE it.{sourceColumn} = @sourceId
            ORDER BY {orderBy}
            OFFSET @offset LIMIT @limit
        ";

        var items = await connection.QueryAsync<T>(
            sql,
            new
            {
                sourceId,
                offset = (pageNumber - 1) * pageSize,
                limit = pageSize
            }
        );

        return (Items: items, TotalCount: totalCount);
    }

    public async Task<(IEnumerable<T> Items, int TotalCount)> GetPaginatedRelatedEntitiesByDateRangeAsync<T>(
        int pageNumber,
        int pageSize,
        string intermediateTable,
        string sourceColumn,   // ex. "task_id"
        int sourceId,          // ex. the task id
        string targetTable,    // ex. "volunteer"
        string targetColumn,   // ex. "volunteer_id"
        DateTime fromDate,
        DateTime toDate,
        string dateColumnName = "created_at",
        string orderBy = "id DESC")
    {
        using var connection = new NpgsqlConnection(connectionString);

        string countSql = $@"
            SELECT COUNT(*) FROM {intermediateTable}
            WHERE {sourceColumn} = @sourceId
                AND {dateColumnName} >= @FromDate AND {dateColumnName} <= @ToDate
        ";
        int totalCount = await connection.ExecuteScalarAsync<int>(countSql, new { sourceId, FromDate = fromDate, ToDate = toDate });

        string sql = $@"
            SELECT t.*
            FROM {intermediateTable} it
            JOIN {targetTable} t ON it.{targetColumn} = t.id
            WHERE it.{sourceColumn} = @sourceId
                AND it.{dateColumnName} >= @FromDate AND it.{dateColumnName} <= @ToDate
            ORDER BY {orderBy}
            OFFSET @offset LIMIT @limit
        ";

        var items = await connection.QueryAsync<T>(
            sql,
            new
            {
                sourceId,
                FromDate = fromDate,
                ToDate = toDate,
                offset = (pageNumber - 1) * pageSize,
                limit = pageSize
            }
        );

        return (Items: items, TotalCount: totalCount);
    }
}
