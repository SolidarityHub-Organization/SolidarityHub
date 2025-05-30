using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using LogicPersistence.Api.Models;
using LogicPersistence.Api.Models.DTOs;
using LogicPersistence.Api.Repositories;
using LogicPersistence.Api.Repositories.Interfaces;
using LogicPersistence.Api.Services;
using Moq;
using Xunit;

namespace LogicPersistence.Tests.Services
{
    public class DashboardServicesTests
    {
        private readonly Mock<IVictimRepository> _mockVictimRepository;
        private readonly Mock<IVolunteerRepository> _mockVolunteerRepository;
        private readonly Mock<IDonationRepository> _mockDonationRepository;
        private readonly DashboardServices _dashboardServices;

        public DashboardServicesTests()
        {
            _mockVictimRepository = new Mock<IVictimRepository>();
            _mockVolunteerRepository = new Mock<IVolunteerRepository>();
            _mockDonationRepository = new Mock<IDonationRepository>();
            _dashboardServices = new DashboardServices(
                _mockVictimRepository.Object,
                _mockVolunteerRepository.Object,
                _mockDonationRepository.Object
            );
        }

        [Fact]
        public async System.Threading.Tasks.Task GetActivityLogDataAsync_WithValidDateRange_ReturnsFilteredActivities()
        {
            // Arrange
            var fromDate = DateTime.Now.AddDays(-7);
            var toDate = DateTime.Now;

            var victims = new List<Victim>
            {
                new Victim { id = 1, name = "Víctima 1", surname = "Apellido 1", created_at = DateTime.Now.AddDays(-5) },
                new Victim { id = 2, name = "Víctima 2", surname = "Apellido 2", created_at = DateTime.Now.AddDays(-3) }
            };

            var volunteers = new List<Volunteer>
            {
                new Volunteer { 
                    id = 1, 
                    name = "Voluntario 1", 
                    surname = "Apellido 1", 
                    created_at = DateTime.Now.AddDays(-4),
                    phone_number = "123456789",
                    prefix = 34
                }
            };

            var monetaryDonations = new List<MonetaryDonation>
            {
                new MonetaryDonation 
                { 
                    id = 1, 
                    volunteer_id = 1, 
                    amount = 100, 
                    currency = Currency.EUR,
                    payment_status = PaymentStatus.Completed,
                    donation_date = DateTime.Now.AddDays(-2)
                }
            };

            _mockVictimRepository.Setup(repo => repo.GetAllVictimsAsync())
                .ReturnsAsync(victims);
            _mockVolunteerRepository.Setup(repo => repo.GetAllVolunteersAsync())
                .ReturnsAsync(volunteers);
            _mockDonationRepository.Setup(repo => repo.GetAllMonetaryDonationsAsync())
                .ReturnsAsync(monetaryDonations);
            _mockVolunteerRepository.Setup(repo => repo.GetVolunteerByIdAsync(1))
                .ReturnsAsync(volunteers[0]);

            // Act
            var result = await _dashboardServices.GetActivityLogDataAsync(fromDate, toDate);

            // Assert
            var activityList = result.ToList();
            Assert.NotNull(activityList);
            Assert.Equal(4, activityList.Count); // 2 víctimas + 1 voluntario + 1 donación
            Assert.Contains(activityList, a => a.type == "Víctima");
            Assert.Contains(activityList, a => a.type == "Voluntario");
            Assert.Contains(activityList, a => a.type == "Donación monetaria");
        }

        [Fact]
        public async System.Threading.Tasks.Task GetActivityLogDataAsync_WithInvalidDateRange_ThrowsArgumentException()
        {
            // Arrange
            var fromDate = DateTime.Now;
            var toDate = DateTime.Now.AddDays(-7); // toDate before fromDate

            // Act & Assert
            await Assert.ThrowsAsync<ArgumentException>(() =>
                _dashboardServices.GetActivityLogDataAsync(fromDate, toDate));
        }

        [Fact]
        public async System.Threading.Tasks.Task GetActivityLogDataAsync_WithEmptyData_ReturnsEmptyList()
        {
            // Arrange
            var fromDate = DateTime.Now.AddDays(-7);
            var toDate = DateTime.Now;

            _mockVictimRepository.Setup(repo => repo.GetAllVictimsAsync())
                .ReturnsAsync(new List<Victim>());
            _mockVolunteerRepository.Setup(repo => repo.GetAllVolunteersAsync())
                .ReturnsAsync(new List<Volunteer>());
            _mockDonationRepository.Setup(repo => repo.GetAllMonetaryDonationsAsync())
                .ReturnsAsync(new List<MonetaryDonation>());

            // Act
            var result = await _dashboardServices.GetActivityLogDataAsync(fromDate, toDate);

            // Assert
            Assert.Empty(result);
        }

        [Fact]
        public async System.Threading.Tasks.Task GetActivityLogDataAsync_WithMonetaryDonations_ReturnsCorrectCurrencyInfo()
        {
            // Arrange
            var fromDate = DateTime.Now.AddDays(-7);
            var toDate = DateTime.Now;
            var donationDate = DateTime.Now.AddDays(-1);

            var volunteer = new Volunteer 
            { 
                id = 1, 
                name = "Voluntario", 
                surname = "Donante", 
                created_at = DateTime.Now.AddDays(-5),
                phone_number = "123456789",
                prefix = 34
            };

            var monetaryDonation = new MonetaryDonation
            {
                id = 1,
                volunteer_id = 1,
                amount = 100,
                currency = Currency.EUR,
                payment_status = PaymentStatus.Completed,
                donation_date = donationDate
            };

            _mockVictimRepository.Setup(repo => repo.GetAllVictimsAsync())
                .ReturnsAsync(new List<Victim>());
            _mockVolunteerRepository.Setup(repo => repo.GetAllVolunteersAsync())
                .ReturnsAsync(new List<Volunteer>());
            _mockDonationRepository.Setup(repo => repo.GetAllMonetaryDonationsAsync())
                .ReturnsAsync(new List<MonetaryDonation> { monetaryDonation });
            _mockVolunteerRepository.Setup(repo => repo.GetVolunteerByIdAsync(1))
                .ReturnsAsync(volunteer);

            // Act
            var result = await _dashboardServices.GetActivityLogDataAsync(fromDate, toDate);

            // Assert
            var activityList = result.ToList();
            var donation = activityList.Find(a => a.type == "Donación monetaria");
            Assert.NotNull(donation);
            Assert.Equal(100, donation.amount);
            Assert.Equal("Euros", donation.currency);
            Assert.Equal(donationDate, donation.date);
            Assert.Contains("Voluntario Donante", donation.name);
        }
    }
} 