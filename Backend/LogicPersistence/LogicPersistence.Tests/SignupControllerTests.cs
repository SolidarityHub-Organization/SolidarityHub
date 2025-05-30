using System.Net.Http;
using System.Net.Http.Json;
using System.Threading.Tasks;
using LogicPersistence.Api.Models.DTOs;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;
using DotNetEnv;
using Dapper;
using Npgsql;

/** Precondiciones:
 * - La base de datos debe estar configurada y accesible.
 * - El archivo .env.development debe contener las variables de entorno necesarias para la conexión a la base de datos.
 */
*/
namespace LogicPersistence.Tests
{
    public class SignupControllerTests : IClassFixture<WebApplicationFactory<App>>
    {
        private readonly HttpClient _client;

        public SignupControllerTests(WebApplicationFactory<App> factory)
        {
            // Load environment variables from .env.development in the test project root
            Env.Load(".env.development");
            _client = factory.CreateClient();
        }

        [Fact]
        public async Task SignupAsync_ValidVolunteer_ReturnsOkAndPersistsUser()
        {
            await SignupAsync_ValidUser_ReturnsOkAndPersistsUser("Volunteer");
        }
        [Fact]
        public async Task SignupAsync_ValidVictim_ReturnsOkAndPersistsUser()
        {
            await SignupAsync_ValidUser_ReturnsOkAndPersistsUser("Victim");
        }
        private async Task SignupAsync_ValidUser_ReturnsOkAndPersistsUser(string requestRole)
        {
            // Arrange
            var uniqueEmail = $"testingEmail_{System.DateTime.UtcNow.Ticks}@example.com";
            var signupJson = new
            {
                name = "Testing Name",
                email = uniqueEmail,
                phone_number = "1234567890",
                prefix = 34,
                address = "123 Testing St",
                surname = "Testing Surname",
                password = "TestingPassword123!",
                identification = "123456789",
                role = requestRole
            };

            // Act
            var response = await _client.PostAsJsonAsync("/api/v1/signup", signupJson);

            // Assert
            if (!response.IsSuccessStatusCode)
            {
                var errorContent = await response.Content.ReadAsStringAsync();
                throw new System.Exception($"Signup failed: {response.StatusCode} - {errorContent}");
            }
            response.EnsureSuccessStatusCode();

            // Comprobar el contenido de la respuesta
            var responseBody = await response.Content.ReadAsStringAsync();
            Assert.False(string.IsNullOrWhiteSpace(responseBody), "La respuesta está vacía");
            System.Console.WriteLine("Respuesta recibida correctamente");

            // Deserializar la respuesta y comparar campos relevantes
            var responseJson = System.Text.Json.JsonDocument.Parse(responseBody).RootElement;
            Assert.Equal(signupJson.name, responseJson.GetProperty("name").GetString());
            System.Console.WriteLine("Nombre comprobado correctamente");
            Assert.Equal(signupJson.email, responseJson.GetProperty("email").GetString());
            System.Console.WriteLine("Email comprobado correctamente");
            Assert.Equal(signupJson.phone_number, responseJson.GetProperty("phone_number").GetString());
            System.Console.WriteLine("Teléfono comprobado correctamente");
            Assert.Equal(signupJson.prefix, responseJson.GetProperty("prefix").GetInt32());
            System.Console.WriteLine("Prefijo comprobado correctamente");
            Assert.Equal(signupJson.address, responseJson.GetProperty("address").GetString());
            System.Console.WriteLine("Dirección comprobada correctamente");
            Assert.Equal(signupJson.surname, responseJson.GetProperty("surname").GetString());
            System.Console.WriteLine("Apellido comprobado correctamente");
            Assert.Equal(signupJson.identification, responseJson.GetProperty("identification").GetString());
            System.Console.WriteLine("Identificación comprobada correctamente");
            //No comprobamos el password por seguridad, ya que no debería ser devuelto en la respuesta

            // Comprobar que el usuario existe en la base de datos
            using (var conn = new Npgsql.NpgsqlConnection(Environment.GetEnvironmentVariable("CONNECTION_STRING") ??
                $"Host={Environment.GetEnvironmentVariable("POSTGRES_HOST")};Port={Environment.GetEnvironmentVariable("POSTGRES_PORT")};Database={Environment.GetEnvironmentVariable("POSTGRES_DB")};Username={Environment.GetEnvironmentVariable("POSTGRES_USER")};Password={Environment.GetEnvironmentVariable("POSTGRES_PASSWORD")}"))
            {
                // Validar el nombre de la tabla para evitar inyección SQL
                string table = requestRole.ToLower() == "volunteer" ? "volunteer" :
                                requestRole.ToLower() == "victim" ? "victim" :
                                throw new ArgumentException("Rol no soportado");
                await conn.OpenAsync();
                var count = await conn.ExecuteScalarAsync<int>($"SELECT COUNT(*) FROM {table} WHERE email = @email", new { email = uniqueEmail });
                Assert.True(count > 0, "El usuario no se ha creado en la base de datos");
                System.Console.WriteLine("Usuario comprobado en base de datos correctamente");
                // Eliminar el usuario de la base de datos tras la prueba
                await conn.ExecuteAsync($"DELETE FROM {table} WHERE email = @email", new { email = uniqueEmail });
                System.Console.WriteLine("Usuario eliminado de la base de datos tras la prueba");
            }
        }

        [Fact]
        public async Task SignupAsync_InvalidUser_ReturnsBadRequest()
        {
            // Arrange
            var invalidSignupJson = new
            {
                name = "Invalid User",
                email = "invalidEmail", // Invalid email format
                phone_number = "12345", // Invalid phone number format
                prefix = 34,
                address = "123 Invalid St",
                surname = "Invalid Surname",
                password = "short", // Too short password
                identification = "123456789",
                role = "Volunteer"
            };

            // Act
            var response = await _client.PostAsJsonAsync("/api/v1/signup", invalidSignupJson);

            // Assert
            Assert.False(response.IsSuccessStatusCode, "Expected BadRequest but got success status code");
            Assert.Equal(System.Net.HttpStatusCode.BadRequest, response.StatusCode);
        }
        [Fact]
        public async Task SignupAsync_EmptyUser_ReturnsBadRequest()
        {
            // Arrange
            var emptySignupJson = new
            {
                name = "",
                email = "",
                phone_number = "",
                prefix = 0,
                address = "",
                surname = "",
                password = "",
                identification = "",
                role = ""
            };

            // Act
            var response = await _client.PostAsJsonAsync("/api/v1/signup", emptySignupJson);

            // Assert
            Assert.False(response.IsSuccessStatusCode, "Expected BadRequest but got success status code");
            Assert.Equal(System.Net.HttpStatusCode.BadRequest, response.StatusCode);
        }
        [Fact]
        public async Task SignupAsync_MissingFields_ReturnsBadRequest()
        {
            // Arrange
            var missingFieldsSignupJson = new
            {
                name = "Missing Fields User",
                // email is missing
                phone_number = "1234567890",
                prefix = 34,
                address = "123 Missing St",
                surname = "Missing Surname",
                password = "ValidPassword123!",
                identification = "987654321",
                role = "Volunteer"
            };

            // Act
            var response = await _client.PostAsJsonAsync("/api/v1/signup", missingFieldsSignupJson);

            // Assert
            Assert.False(response.IsSuccessStatusCode, "Expected BadRequest but got success status code");
            Assert.Equal(System.Net.HttpStatusCode.BadRequest, response.StatusCode);
        }
    }
}
