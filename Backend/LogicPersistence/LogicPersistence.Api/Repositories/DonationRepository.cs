using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;
using LogicPersistence.Api.Repositories.Interfaces;
using System.Data;

namespace LogicPersistence.Api.Repositories;

public class DonationRepository : IDonationRepository {
    private readonly string connectionString = DatabaseConfiguration.Instance.GetConnectionString();

#region PhysicalDonation
    public async Task<PhysicalDonation> CreatePhysicalDonationAsync(PhysicalDonation donation) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            INSERT INTO physical_donation (item_name, description, quantity, item_type, donation_date, volunteer_id, admin_id, victim_id)
            VALUES (@item_name, @description, @quantity, @item_type::item_type, @donation_date, @volunteer_id, @admin_id, @victim_id)
            RETURNING *";

        var parameters = new
        {
            item_name = donation.item_name,
            description = donation.description,
            quantity = donation.quantity,
            item_type = donation.item_type.ToString(),
            donation_date = donation.donation_date,
            volunteer_id = donation.volunteer_id,
            admin_id = donation.admin_id,
            victim_id = donation.victim_id
        };

        return await connection.QuerySingleAsync<PhysicalDonation>(sql, parameters);
    }

    public async Task<PhysicalDonation> UpdatePhysicalDonationAsync(PhysicalDonation donation) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            UPDATE physical_donation 
            SET item_name = @item_name,
                description = @description,
                quantity = @quantity,
                item_type = @item_type::item_type,
                donation_date = @donation_date,
                volunteer_id = @volunteer_id,
                admin_id = @admin_id,
                victim_id = @victim_id
            WHERE id = @id
            RETURNING *";

        var parameters = new
        {
            id = donation.id,
            item_name = donation.item_name,
            description = donation.description,
            quantity = donation.quantity,
            item_type = donation.item_type.ToString(),
            donation_date = donation.donation_date,
            volunteer_id = donation.volunteer_id,
            admin_id = donation.admin_id,
            victim_id = donation.victim_id
        };

        return await connection.QuerySingleAsync<PhysicalDonation>(sql, parameters);
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
        const string sql = @"
            SELECT 
                id,
                item_name,
                description,
                quantity,
                item_type::text as item_type,
                donation_date,
                volunteer_id,
                admin_id,
                victim_id,
                created_at
            FROM physical_donation 
            WHERE id = @id";

        return await connection.QuerySingleOrDefaultAsync<PhysicalDonation>(sql, new { id });
    }

    public async Task<IEnumerable<PhysicalDonation>> GetAllPhysicalDonationsAsync() 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            SELECT 
                id,
                item_name,
                description,
                quantity,
                item_type::text as item_type,
                donation_date,
                volunteer_id,
                admin_id,
                victim_id,
                created_at
            FROM physical_donation";

        var donations = await connection.QueryAsync<PhysicalDonation>(sql);
        return donations;
    }

    public async Task<int> GetTotalAmountPhysicalDonationsAsync(DateTime fromDate, DateTime toDate) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            SELECT COALESCE(SUM(quantity), 0) 
            FROM physical_donation 
            WHERE donation_date BETWEEN @fromDate AND @toDate";

        return await connection.QuerySingleOrDefaultAsync<int>(sql, new { fromDate, toDate });
    }
#endregion
#region MonetaryDonation
    public async Task<MonetaryDonation> CreateMonetaryDonationAsync(MonetaryDonation donation) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            INSERT INTO monetary_donation (amount, currency, payment_status, transaction_id, payment_service, donation_date, volunteer_id, admin_id, victim_id)
            VALUES (@amount, @currency::currency, @payment_status::payment_status, @transaction_id, @payment_service::payment_service, @donation_date, @volunteer_id, @admin_id, @victim_id) 
            RETURNING *";

        var parameters = new
        {
            amount = donation.amount,
            currency = donation.currency.ToString(),
            payment_status = donation.payment_status.ToString(),
            transaction_id = donation.transaction_id,
            payment_service = donation.payment_service.ToString(),
            donation_date = donation.donation_date,
            volunteer_id = donation.volunteer_id,
            admin_id = donation.admin_id,
            victim_id = donation.victim_id
        };

        return await connection.QuerySingleAsync<MonetaryDonation>(sql, parameters);
    }

    public async Task<MonetaryDonation> UpdateMonetaryDonationAsync(MonetaryDonation donation) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            UPDATE monetary_donation 
            SET amount = @amount,
                currency = @currency::currency,
                payment_status = @payment_status::payment_status,
                transaction_id = @transaction_id,
                payment_service = @payment_service::payment_service,
                donation_date = @donation_date,
                volunteer_id = @volunteer_id,
                admin_id = @admin_id,
                victim_id = @victim_id
            WHERE id = @id
            RETURNING *";

        var parameters = new
        {
            id = donation.id,
            amount = donation.amount,
            currency = donation.currency.ToString(),
            payment_status = donation.payment_status.ToString(),
            transaction_id = donation.transaction_id,
            payment_service = donation.payment_service.ToString(),
            donation_date = donation.donation_date,
            volunteer_id = donation.volunteer_id,
            admin_id = donation.admin_id,
            victim_id = donation.victim_id
        };

        return await connection.QuerySingleAsync<MonetaryDonation>(sql, parameters);
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
        const string sql = @"
            SELECT 
                id,
                amount,
                currency::text as currency,
                payment_status::text as payment_status,
                transaction_id,
                payment_service::text as payment_service,
                donation_date,
                volunteer_id,
                admin_id,
                victim_id,
                created_at
            FROM monetary_donation";

        return await connection.QueryAsync<MonetaryDonation>(sql);
    }

    public async Task<double> GetTotalMonetaryAmountByCurrencyAsync(Currency currency, DateTime fromDate, DateTime toDate) 
    {
        using var connection = new NpgsqlConnection(connectionString);
        const string sql = @"
            SELECT COALESCE(SUM(amount), 0) 
            FROM monetary_donation 
            WHERE currency::text = @currency::text 
            AND payment_status = 'Completed'::payment_status 
            AND created_at BETWEEN @fromDate AND @toDate";

        return await connection.QuerySingleOrDefaultAsync<double>(sql, new { currency = currency.ToString(), fromDate, toDate });
    }
#endregion
}