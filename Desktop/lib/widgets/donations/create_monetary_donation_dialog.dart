import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solidarityhub/models/donation.dart';
import 'package:solidarityhub/models/volunteer.dart';

class CreateMonetaryDonationDialog extends StatefulWidget {
  final List<Volunteer> volunteers;

  const CreateMonetaryDonationDialog({Key? key, required this.volunteers}) : super(key: key);

  @override
  _CreateMonetaryDonationDialogState createState() => _CreateMonetaryDonationDialogState();
}

class _CreateMonetaryDonationDialogState extends State<CreateMonetaryDonationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _transactionIdController = TextEditingController();
  Currency _selectedCurrency = Currency.EUR;
  PaymentService _selectedPaymentService = PaymentService.BankTransfer;
  Volunteer? _selectedVolunteer;

  @override
  void initState() {
    super.initState();
    if (widget.volunteers.isNotEmpty) {
      _selectedVolunteer = widget.volunteers.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _transactionIdController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva Donación Monetaria'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Cantidad', prefixText: getCurrencySymbol(_selectedCurrency)),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una cantidad';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Por favor ingrese una cantidad válida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Currency>(
                value: _selectedCurrency,
                decoration: const InputDecoration(labelText: 'Moneda'),
                items:
                    Currency.values
                        .where((c) => c != Currency.Other)
                        .map((currency) => DropdownMenuItem(value: currency, child: Text(currency.name)))
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCurrency = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PaymentService>(
                value: _selectedPaymentService,
                decoration: const InputDecoration(labelText: 'Método de pago'),
                items:
                    PaymentService.values
                        .where((p) => p != PaymentService.Other)
                        .map((service) => DropdownMenuItem(value: service, child: Text(service.name)))
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPaymentService = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _transactionIdController,
                decoration: const InputDecoration(labelText: 'ID de Transacción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un ID de transacción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Volunteer>(
                value: _selectedVolunteer,
                decoration: const InputDecoration(labelText: 'Voluntario'),
                items:
                    widget.volunteers
                        .map(
                          (volunteer) =>
                              DropdownMenuItem(value: volunteer, child: Text('${volunteer.name} ${volunteer.surname}')),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVolunteer = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor seleccione un voluntario';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newDonation = MonetaryDonation(
                id: 0, // El ID será asignado por el backend
                amount: double.parse(_amountController.text),
                currency: _selectedCurrency,
                paymentStatus: PaymentStatus.Pending,
                paymentService: _selectedPaymentService,
                transactionId: _transactionIdController.text,
                volunteer: _selectedVolunteer,
              );
              Navigator.pop(context, newDonation);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          child: const Text('Crear'),
        ),
      ],
    );
  }
}
