namespace LogicPersistence.Api.Models;

// pickup points can hold several items/donations
public class PointDonation {
	public int point_id { get; set; }
	public int donation_id { get; set; }
}