namespace LogicPersistence.Api.Repositories;

using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;

public class AdminRepository : IAdminRepository
{
    private readonly string connectionString = DatabaseConfiguration.GetConnectionString();

    public async Task<Admin> CreateAdminAsync(Admin admin)
    {;
        if (await EmailExistsAsync(admin.email))
        {
            throw new Exception("El email ya está en uso.");
        }
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            INSERT INTO admin (jurisdiction, email, password, name, surname, prefix, phone_number, address, identification)
            VALUES (@jurisdiction, @email, @password, @name, @surname ,@prefix, @phone_number, @address, @identification)
            RETURNING *";  // Return all columns instead of just id

        return await connection.QuerySingleAsync<Admin>(sql, admin);  // Get the complete record back with QuerySingleAsync (works with RETURNING *)
    }

    public async Task<Admin> UpdateAdminAsync(Admin admin)
    {      
        if (await EmailExistsAsync(admin.email))
        {
            throw new Exception("El email ya está en uso.");
        }
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            UPDATE admin
            SET id = @id,
                jurisdiction = @jurisdiction,
                email = @email,
                password = @password,
                name = @name,
                surname = @surname,
                prefix = @prefix,
                phone_number = @phone_number,
                address = @address,
                identification = @identification
            WHERE id = @id
            RETURNING *";

        return await connection.QuerySingleAsync<Admin>(sql, admin);
    }

    public async Task<bool> DeleteAdminAsync(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "DELETE FROM admin WHERE id = @id";

        int rowsAffected = await connection.ExecuteAsync(sql, new { id });
        return rowsAffected > 0;
    }

    public async Task<IEnumerable<Admin>> GetAllAdminAsync()
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "SELECT * FROM admin";

        return await connection.QueryAsync<Admin>(sql);
    }

    public async Task<Admin?> GetAdminByIdAsync(int id)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "SELECT * FROM admin WHERE id = @id";

        return await connection.QuerySingleOrDefaultAsync<Admin>(sql, new { id });
    }

    public async Task<Admin?> GetAdminByEmailAsync(string email)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "SELECT * FROM admin WHERE email = @email";

        return await connection.QuerySingleOrDefaultAsync<Admin>(sql, new { email });
    }

    public async Task<Admin?> GetAdminByJurisdictionAsync(string jurisdiction)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "SELECT * FROM admin WHERE jurisdiction = @jurisdiction";

        return await connection.QuerySingleOrDefaultAsync<Admin>(sql, new { jurisdiction });
    }

    public async Task<bool> EmailExistsAsync(string email)
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "SELECT COUNT(1) FROM admin WHERE email = @Email";

        int count = await connection.ExecuteScalarAsync<int>(sql, new { Email = email });
        return count > 0;
    }
}