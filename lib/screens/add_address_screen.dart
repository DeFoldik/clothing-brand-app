import 'package:flutter/material.dart';
import '../models/delivery_address.dart';
import '../services/address_service.dart';

class AddAddressScreen extends StatefulWidget {
  final Function(DeliveryAddress)? onAddressAdded;
  final DeliveryAddress? editAddress;

  const AddAddressScreen({
    super.key,
    this.onAddressAdded,
    this.editAddress,
  });

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _apartmentController = TextEditingController();
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editAddress != null) {
      _fillFormWithAddress(widget.editAddress!);
    } else {
      _titleController.text = 'Основной адрес';
    }
  }

  void _fillFormWithAddress(DeliveryAddress address) {
    _titleController.text = address.title;
    _fullNameController.text = address.fullName;
    _phoneController.text = address.phone;
    _streetController.text = address.street;
    _cityController.text = address.city;
    _postalCodeController.text = address.postalCode;
    _apartmentController.text = address.apartment ?? '';
    _isDefault = address.isDefault;
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 🎯 ИСПРАВЛЕНИЕ: Для редактирования используем существующий ID, для создания - пустой
      final address = DeliveryAddress(
        id: widget.editAddress?.id ?? '', // Для нового адреса - пустая строка
        title: _titleController.text.trim(),
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        apartment: _apartmentController.text.trim().isNotEmpty ? _apartmentController.text.trim() : null,
        isDefault: _isDefault,
        createdAt: widget.editAddress?.createdAt ?? DateTime.now(), // Сохраняем оригинальную дату создания при редактировании
      );

      if (widget.editAddress != null) {
        // 🎯 ПРОВЕРКА: Убедимся, что ID не пустой при редактировании
        if (address.id.isEmpty) {
          throw Exception('ID адреса не может быть пустым при редактировании');
        }
        await AddressService.updateAddress(address);
      } else {
        await AddressService.addAddress(address);
      }

      if (widget.onAddressAdded != null) {
        widget.onAddressAdded!(address);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.editAddress != null ? 'Адрес обновлен' : 'Адрес добавлен'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editAddress != null ? 'Редактировать адрес' : 'Добавить адрес'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Название адреса',
                    hintText: 'Например: Дом, Работа',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите название адреса';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'ФИО получателя',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите ФИО получателя';
                    }
                    if (RegExp(r'[0-9]').hasMatch(value)) {
                      return 'ФИО не может содержать цифры';
                    }
                    if (!RegExp(r'^[a-zA-Zа-яА-ЯёЁ\s\-]+$').hasMatch(value)) {
                      return 'ФИО может содержать только буквы, пробелы и дефисы';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Телефон',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите телефон';
                    }
                    final cleanPhone = value.replaceAll(' ', '').replaceAll('-', '').replaceAll('(', '').replaceAll(')', '');
                    if (!RegExp(r'^\+?[0-9]{10,}$').hasMatch(cleanPhone)) {
                      return 'Введите корректный номер телефона';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _streetController,
                  decoration: const InputDecoration(
                    labelText: 'Улица, дом',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите улицу и дом';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'Город',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введите город';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _postalCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Индекс',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Введите индекс';
                          }
                          if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                            return 'Индекс должен содержать 6 цифр';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _apartmentController,
                  decoration: const InputDecoration(
                    labelText: 'Квартира/Офис (необязательно)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Использовать по умолчанию'),
                  value: _isDefault,
                  onChanged: (value) {
                    setState(() {
                      _isDefault = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAddress,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Text(widget.editAddress != null ? 'Сохранить изменения' : 'Добавить адрес'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _apartmentController.dispose();
    super.dispose();
  }
}