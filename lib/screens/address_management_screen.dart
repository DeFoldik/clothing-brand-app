import 'package:flutter/material.dart';
import '../services/address_service.dart';
import '../models/delivery_address.dart';
import 'add_address_screen.dart';

class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  State<AddressManagementScreen> createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  Stream<List<DeliveryAddress>>? _addressesStream;

  @override
  void initState() {
    super.initState();
    _addressesStream = AddressService.getAddressesStream();
  }

  void _editAddress(DeliveryAddress address) {
    print('✏️ Редактирование адреса: ${address.id} - ${address.title}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(editAddress: address),
      ),
    );
  }

  Future<void> _deleteAddress(DeliveryAddress address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить адрес?'),
        content: Text('Вы уверены, что хотите удалить адрес "${address.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AddressService.deleteAddress(address.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Адрес удален'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка удаления: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои адреса'),
        actions: [
          IconButton(
            onPressed: () {
              AddressService.debugAddresses();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Отладка запущена - смотрите логи')),
              );
            },
            icon: const Icon(Icons.bug_report),
            tooltip: 'Отладка адресов',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAddressScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<DeliveryAddress>>(
        stream: _addressesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Ошибка загрузки адресов'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _addressesStream = AddressService.getAddressesStream();
                    }),
                    child: const Text('Попробовать снова'),
                  ),
                ],
              ),
            );
          }

          final addresses = snapshot.data ?? [];

          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'У вас нет сохраненных адресов',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Добавьте адрес для доставки заказов',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return _buildAddressCard(address);
            },
          );
        },
      ),
    );
  }

  Widget _buildAddressCard(DeliveryAddress address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  address.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (address.isDefault)
                  Container(
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
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(address.fullName),
            Text(address.phone),
            Text(address.fullAddress),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: () => _editAddress(address),
                  child: const Text('Редактировать'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _deleteAddress(address),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Удалить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}