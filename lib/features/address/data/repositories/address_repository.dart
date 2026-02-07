import '../../../core/network/api_client.dart';
import '../domain/entities/saved_address.dart';

class AddressRepository {
  final ApiClient _apiClient;

  AddressRepository(this._apiClient);

  /// Get all saved addresses for the current user
  Future<List<SavedAddress>> getAddresses() async {
    try {
      final response = await _apiClient.get('/v1/addresses');
      final data = response.data;

      if (data['success'] == true) {
        final List<dynamic> addressList = data['data'] ?? [];
        return addressList
            .map((json) => SavedAddress.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      throw Exception(data['message'] ?? 'Failed to load addresses');
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new saved address
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
  }) async {
    try {
      final response = await _apiClient.post('/v1/addresses', data: {
        'label': label,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'contact_name': contactName,
        'contact_phone': contactPhone,
        'instructions': instructions,
        'is_default': isDefault,
        'type': type,
      });
      
      final data = response.data;

      if (data['success'] == true) {
        return SavedAddress.fromJson(data['data'] as Map<String, dynamic>);
      }
      
      throw Exception(data['message'] ?? 'Failed to create address');
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing saved address
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
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (label != null) data['label'] = label;
      if (address != null) data['address'] = address;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;
      if (contactName != null) data['contact_name'] = contactName;
      if (contactPhone != null) data['contact_phone'] = contactPhone;
      if (instructions != null) data['instructions'] = instructions;
      if (isDefault != null) data['is_default'] = isDefault;
      if (type != null) data['type'] = type;

      final response = await _apiClient.put('/v1/addresses/$id', data: data);
      final responseData = response.data;

      if (responseData['success'] == true) {
        return SavedAddress.fromJson(responseData['data'] as Map<String, dynamic>);
      }
      
      throw Exception(responseData['message'] ?? 'Failed to update address');
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a saved address
  Future<void> deleteAddress(int id) async {
    try {
      final response = await _apiClient.delete('/v1/addresses/$id');
      final data = response.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to delete address');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Set an address as default
  Future<SavedAddress> setDefaultAddress(int id) async {
    try {
      final response = await _apiClient.post('/v1/addresses/$id/set-default');
      final data = response.data;

      if (data['success'] == true) {
        return SavedAddress.fromJson(data['data'] as Map<String, dynamic>);
      }
      
      throw Exception(data['message'] ?? 'Failed to set default address');
    } catch (e) {
      rethrow;
    }
  }
}
