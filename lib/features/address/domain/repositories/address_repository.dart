import '../entities/saved_address.dart';

abstract class AddressRepositoryInterface {
  Future<List<SavedAddress>> getAddresses();
  Future<SavedAddress> createAddress({
    required String label,
    required String address,
    required double latitude,
    required double longitude,
    String? contactName,
    String? contactPhone,
    String? instructions,
    bool isDefault = false,
    String type = 'other',
  });
  Future<SavedAddress> updateAddress({
    required int id,
    String? label,
    String? address,
    double? latitude,
    double? longitude,
    String? contactName,
    String? contactPhone,
    String? instructions,
    bool? isDefault,
    String? type,
  });
  Future<void> deleteAddress(int id);
  Future<SavedAddress> setDefaultAddress(int id);
}
