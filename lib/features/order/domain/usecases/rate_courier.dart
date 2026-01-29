import '../entities/order.dart';
import '../repositories/order_repository.dart';

class RateCourierUseCase {
  final OrderRepository repository;

  RateCourierUseCase(this.repository);

  Future<Order> call({
    required String orderId,
    required int rating,
    String? review,
    List<String>? tags,
  }) async {
    // Validation de la note
    if (rating < 1 || rating > 5) {
      throw ArgumentError('La note doit être entre 1 et 5');
    }

    // Validation de la review
    if (review != null && review.length > 500) {
      throw ArgumentError('Le commentaire ne peut pas dépasser 500 caractères');
    }

    return await repository.rateCourier(
      orderId: orderId,
      rating: rating,
      review: review,
      tags: tags,
    );
  }
}
