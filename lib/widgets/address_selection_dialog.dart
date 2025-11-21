// widgets/address_selection_dialog.dart
import 'package:flutter/material.dart';
import '../models/delivery_address.dart';
import '../services/address_service.dart';
import '../screens/add_address_screen.dart';

class AddressSelectionDialog extends StatefulWidget {
  const AddressSelectionDialog({super.key});

  @override
  State<AddressSelectionDialog> createState() => _AddressSelectionDialogState();
}

class _AddressSelectionDialogState extends State<AddressSelectionDialog> {
  DeliveryAddress? _selectedAddress;
  List<DeliveryAddress> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final addressesStream = AddressService.getAddressesStream();
      addressesStream.first.then((addresses) {
        if (mounted) {
          setState(() {
            _addresses = addresses;
            _isLoading = false;
            // Выбираем адрес по умолчанию или первый доступный
            if (addresses.isNotEmpty) {
              _selectedAddress = addresses.firstWhere(
                    (addr) => addr.isDefault,
                orElse: () => addresses.first,
              );
            }
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Выберите адрес доставки'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
          ? const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'У вас нет сохраненных адресов',
            textAlign: TextAlign.center,
          ),
        ],
      )
          : SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _addresses.length,
          itemBuilder: (context, index) {
            final address = _addresses[index];
            return _buildAddressCard(address);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        if (_addresses.isNotEmpty)
          ElevatedButton(
            onPressed: _selectedAddress != null
                ? () => Navigator.pop(context, _selectedAddress)
                : null,
            child: const Text('Выбрать'),
          ),
        TextButton(
          onPressed: () => _addNewAddress(context),
          child: const Text('Добавить новый'),
        ),
      ],
    );
  }

  Widget _buildAddressCard(DeliveryAddress address) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: _selectedAddress?.id == address.id ? Colors.blue[50] : null,
      child: ListTile(
        leading: Radio<DeliveryAddress>(
          value: address,
          groupValue: _selectedAddress,
          onChanged: (value) {
            setState(() {
              _selectedAddress = value;
            });
          },
        ),
        title: Text(
          address.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: address.isDefault ? Colors.blue : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(address.fullName),
            Text(address.phone),
            Text(address.fullAddress),
          ],
        ),
        trailing: address.isDefault
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'По умолчанию',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        )
            : null,
        onTap: () {
          setState(() {
            _selectedAddress = address;
          });
        },
      ),
    );
  }

  void _addNewAddress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(
          onAddressAdded: (newAddress) {
            Navigator.pop(context, newAddress);
          },
        ),
      ),
    );
  }
}