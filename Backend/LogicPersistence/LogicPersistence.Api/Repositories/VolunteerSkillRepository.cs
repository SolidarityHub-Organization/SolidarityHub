using Dapper;
using LogicPersistence.Api.Models;
using Npgsql;

namespace LogicPersistence.Api.Repositories
{
    public class VolunteerSkillRepository : IVolunteerSkillRepository
    {
        private readonly string _connectionString = DatabaseConfiguration.GetConnectionString();

        public async Task<VolunteerSkill> CreateVolunteerSkillAsync(VolunteerSkill volunteerSkill)
        {
            using var connection = new NpgsqlConnection(_connectionString);
            const string sql = @"
                INSERT INTO volunteer_skill (volunteer_id, skill_id)
                VALUES (@volunteer_id, @skill_id)
                RETURNING *";
            return await connection.QuerySingleAsync<VolunteerSkill>(sql, volunteerSkill);
        }

        public async Task<VolunteerSkill?> GetVolunteerSkillByIdAsync(int volunteer_id, int skill_id)
        {
            using var connection = new NpgsqlConnection(_connectionString);
            const string sql = "SELECT * FROM volunteer_skill WHERE volunteer_id = @volunteer_id AND skill_id = @skill_id";
            return await connection.QuerySingleOrDefaultAsync<VolunteerSkill>(sql, new { volunteer_id, skill_id });
        }

        public async Task<VolunteerSkill> UpdateVolunteerSkillAsync(VolunteerSkill volunteerSkill)
        {
            using var connection = new NpgsqlConnection(_connectionString);
            const string sql = @"
                UPDATE volunteer_skill
                SET volunteer_id = @volunteer_id, skill_id = @skill_id
                WHERE volunteer_id = @volunteer_id AND skill_id = @skill_id
                RETURNING *";
            return await connection.QuerySingleAsync<VolunteerSkill>(sql, volunteerSkill);
        }

        public async System.Threading.Tasks.Task DeleteVolunteerSkillAsync(int volunteer_id, int skill_id)
        {
            using var connection = new NpgsqlConnection(_connectionString);
            const string sql = "DELETE FROM volunteer_skill WHERE volunteer_id = @volunteer_id AND skill_id = @skill_id";
            await connection.ExecuteAsync(sql, new { volunteer_id, skill_id });
        }

        public async Task<IEnumerable<VolunteerSkill>> GetAllVolunteerSkillsAsync()
        {
            using var connection = new NpgsqlConnection(_connectionString);
            const string sql = "SELECT * FROM volunteer_skill";
            return await connection.QueryAsync<VolunteerSkill>(sql);
        }
    }
}
