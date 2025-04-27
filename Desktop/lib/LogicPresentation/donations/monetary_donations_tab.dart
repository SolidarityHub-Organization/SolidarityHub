import 'package:flutter/material.dart';
import 'package:solidarityhub/LogicPersistence/models/donation.dart';

class MonetaryDonationsTab extends StatefulWidget {
  final List<MonetaryDonation> donations;
  final bool isLoading;
  final String? errorMessage;
  final Function() onRefresh;

  const MonetaryDonationsTab({
    Key? key,
    required this.donations,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
  }) : super(key: key);

  @override
  _MonetaryDonationsTabState createState() => _MonetaryDonationsTabState();
}

class _MonetaryDonationsTabState extends State<MonetaryDonationsTab> {
  String getCurrencySymbol(Currency currency) {
    switch (currency) {
      case Currency.EUR:
        return '€';
      case Currency.USD:
        return '\$';
      default:
        return '';
    }
  }

  Color getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.Completed:
        return Colors.green;
      case PaymentStatus.Pending:
        return Colors.orange;
      case PaymentStatus.Failed:
        return Colors.red;
      case PaymentStatus.Refunded:
        return Colors.blue;
    }
  }

  Widget _buildMonetaryDonationCard(MonetaryDonation donation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${getCurrencySymbol(donation.currency)}${donation.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    donation.paymentStatus.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: getStatusColor(donation.paymentStatus),
                ),
              ],
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.payment),
              title: Text('Método de pago: ${donation.paymentService.name}'),
              subtitle: Text('ID Transacción: ${donation.transactionId}'),
            ),
            if (donation.volunteer != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person),
                title: Text(
                  'Donante: ${donation.volunteer!.name} ${donation.volunteer!.surname}',
                ),
              ),
            if (donation.assignedVictim != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: Text(
                  'Asignado a: ${donation.assignedVictim!.name} ${donation.assignedVictim!.surname}',
                ),
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(
                'Fecha: ${donation.donationDate.toLocal().toString().split('.')[0]}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.errorMessage!),
            ElevatedButton(
              onPressed: widget.onRefresh,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Donaciones Monetarias',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (widget.donations.isEmpty)
            const Center(
              child: Text(
                'No hay donaciones monetarias disponibles',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.donations.length,
              itemBuilder:
                  (context, index) =>
                      _buildMonetaryDonationCard(widget.donations[index]),
            ),
        ],
      ),
    );
  }
}
