using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;
using LogicPersistence.Api.Repositories.Interfaces;

namespace LogicPersistence.Api.Repositories;

public class DonationRepository : IDonationRepository {
    private readonly string connectionString = DatabaseConfiguration.GetConnectionString();

    #region PhysicalDonation
    public async Task<PhysicalDonation> CreatePhysicalDonationAsync(PhysicalDonation donation) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            INSERT INTO physical_donation (item_name, description, quantity, item_type, donation_date, volunteer_id, admin_id, victim_id)
            VALUES (@item_name, @description, @quantity, @item_type, @donation_date, @volunteer_id, @admin_id, @victim_id)
            RETURNING *";

        return await connection.QuerySingleAsync<PhysicalDonation>(sql, donation);
    }

    public async Task<PhysicalDonation> UpdatePhysicalDonationAsync(PhysicalDonation donation) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            UPDATE physical_donation 
            SET item_name = @item_name,
                description = @description,
                quantity = @quantity,
                item_type = @item_type,
                donation_date = @donation_date,
                volunteer_id = @volunteer_id,
                admin_id = @admin_id,
                victim_id = @victim_id
            WHERE id = @id
            RETURNING *";

        return await connection.QuerySingleAsync<PhysicalDonation>(sql, donation);
    }

    public async Task<bool> DeletePhysicalDonationAsync(int id) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "DELETE FROM physical_donation WHERE id = @id";

        int rowsAffected = await connection.ExecuteAsync(sql, new { id });
        return rowsAffected > 0;
    }

    public async Task<PhysicalDonation?> GetPhysicalDonationByIdAsync(int id) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "SELECT * FROM physical_donation WHERE id = @id";

        return await connection.QuerySingleOrDefaultAsync<PhysicalDonation>(sql, new { id });
    }

    public async Task<IEnumerable<PhysicalDonation>> GetAllPhysicalDonationsAsync() 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "SELECT * FROM physical_donation";

        return await connection.QueryAsync<PhysicalDonation>(sql);
    }
    #endregion

    #region MonetaryDonation
    #endregion
}