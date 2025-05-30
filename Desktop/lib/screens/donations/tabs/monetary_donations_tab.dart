import 'package:flutter/material.dart';
import 'package:solidarityhub/models/donation.dart';
import 'package:solidarityhub/services/donation_services.dart';
import 'package:solidarityhub/widgets/donations/create_monetary_donation_dialog.dart';
import 'package:solidarityhub/models/volunteer.dart';

class MonetaryDonationsTab extends StatefulWidget {
  final List<MonetaryDonation> donations;
  final bool isLoading;
  final String? errorMessage;
  final Function() onRefresh;
  final List<Volunteer> volunteers;

  const MonetaryDonationsTab({
    Key? key,
    required this.donations,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.volunteers,
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

  Future<void> _showCreateMonetaryDonationDialog() async {
    final result = await showDialog<MonetaryDonation>(
      context: context,
      builder: (context) => CreateMonetaryDonationDialog(volunteers: widget.volunteers),
    );

    if (result != null) {
      try {
        final createdDonation = await DonationServices.createMonetaryDonation(result);
        widget.onRefresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Donación monetaria creada exitosamente'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _deleteMonetaryDonation(MonetaryDonation donation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text(
              '¿Está seguro de que desea eliminar la donación monetaria de ${donation.amount} ${donation.currency.name}?',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await DonationServices.deleteMonetaryDonation(donation.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Donación eliminada exitosamente'), backgroundColor: Colors.green),
          );
          widget.onRefresh();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
          );
        }
      }
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
                Expanded(
                  child: Text(
                    '${getCurrencySymbol(donation.currency)}${donation.amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _deleteMonetaryDonation(donation),
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
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
                title: Text('Donante: ${donation.volunteer!.name} ${donation.volunteer!.surname}'),
              ),
            if (donation.assignedVictim != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: Text('Asignado a: ${donation.assignedVictim!.name} ${donation.assignedVictim!.surname}'),
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text('Fecha: ${donation.donationDate.toLocal().toString().split('.')[0]}'),
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
            Text(widget.errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: widget.onRefresh, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Donaciones Monetarias', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: _showCreateMonetaryDonationDialog,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Nueva Donación', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
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
              itemBuilder: (context, index) => _buildMonetaryDonationCard(widget.donations[index]),
            ),
        ],
      ),
    );
  }
}
