namespace LogicPersistence.Api.Services;

using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Services.Interfaces;


public class PaginationService : IPaginationService {
    private readonly IPaginationRepository _paginationRepository;

    public PaginationService(IPaginationRepository paginationRepository) {
        _paginationRepository = paginationRepository;
    }

    public async Task<(IEnumerable<T> Items, int TotalCount)> GetPaginatedAsync<T>(
        int pageNumber,
        int pageSize,
        string tableName,
        string orderBy = "created_at DESC, id DESC") {
        if (pageNumber < 1)
            throw new ArgumentException("Page number must be greater than or equal to 1.");

        if (pageSize < 1)
            throw new ArgumentException("Page size must be greater than or equal to 1.");

        if (string.IsNullOrWhiteSpace(tableName))
            throw new ArgumentException("Table name cannot be empty.");


        var result = await _paginationRepository.GetPaginatedAsync<T>(pageNumber, pageSize, tableName, orderBy);


        if (result.Items == null)
            throw new InvalidOperationException($"Failed to retrieve paginated {typeof(T).Name}s.");


        int totalPages = (int)Math.Ceiling(result.TotalCount / (double)pageSize);
        if (totalPages > 0 && pageNumber > totalPages)
            throw new ArgumentException($"Page number {pageNumber} exceeds total pages {totalPages}.");

        return result;
    }
}
