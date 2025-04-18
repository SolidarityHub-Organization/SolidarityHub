using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;
using LogicPersistence.Api.Repositories.Interfaces;
using System.Data;

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

    public async Task<int> GetTotalAmountPhysicalDonationsAsync() 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "SELECT SUM(quantity) FROM physical_donation;";

        return await connection.QuerySingleOrDefaultAsync<int>(sql);
    }
#endregion
#region MonetaryDonation
    public async Task<MonetaryDonation> CreateMonetaryDonationAsync(MonetaryDonation donation) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            INSERT INTO monetary_donation (amount, currency, payment_status, transaction_id, payment_service, donation_date, volunteer_id, admin_id, victim_id)
            VALUES (@amount, @currency, @payment_status, @transaction_id, @payment_service, @donation_date, @volunteer_id, @admin_id, @victim_id) 
            RETURNING *";

        return await connection.QuerySingleAsync<MonetaryDonation>(sql, donation);
    }

    public async Task<MonetaryDonation> UpdateMonetaryDonationAsync(MonetaryDonation donation) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            UPDATE monetary_donation 
            SET amount = @amount,
                currency = @currency,
                payment_status = @payment_status,
                transaction_id = @transaction_id,
                payment_service = @payment_service,
                donation_date = @donation_date,
                volunteer_id = @volunteer_id,
                admin_id = @admin_id,
                victim_id = @victim_id
            WHERE id = @id
            RETURNING *";

        return await connection.QuerySingleAsync<MonetaryDonation>(sql, donation);
    }

    public async Task<bool> DeleteMonetaryDonationAsync(int id) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "DELETE FROM monetary_donation WHERE id = @id";

        int rowsAffected = await connection.ExecuteAsync(sql, new { id });
        return rowsAffected > 0;
    }

    public async Task<MonetaryDonation?> GetMonetaryDonationByIdAsync(int id) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "SELECT * FROM monetary_donation WHERE id = @id";

        return await connection.QuerySingleOrDefaultAsync<MonetaryDonation>(sql, new { id });
    }

    public async Task<IEnumerable<MonetaryDonation>> GetAllMonetaryDonationsAsync() 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = "SELECT * FROM monetary_donation";

        return await connection.QueryAsync<MonetaryDonation>(sql);
    }

    public async Task<double> GetTotalMonetaryAmountByCurrencyAsync(Currency currency) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            SELECT COALESCE(SUM(amount), 0) 
            FROM monetary_donation 
            WHERE currency::text = @currency::text 
            AND payment_status = 'Completed'::payment_status";

        return await connection.QuerySingleOrDefaultAsync<double>(sql, new { currency = currency.ToString() });
    }
#endregion
}