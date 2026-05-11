import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Mixin pour les BLoCs/Cubits fournissant un `safeEmit`
/// qui vérifie `isClosed` avant d'émettre un nouvel état.
///
/// Usage :
/// ```dart
/// class MyBloc extends Bloc<MyEvent, MyState> with SafeEmitMixin {
///   ...
///   Future<void> _onSomething(event, emit) async {
///     safeEmit(emit, LoadingState());
///     ...
///   }
/// }
/// ```
mixin SafeEmitMixin<State> on BlocBase<State> {
  /// Émet [newState] uniquement si le BLoC/Cubit n'est pas fermé.
  /// Retourne `true` si l'état a été émis, `false` sinon.
  bool safeEmit(Emitter<State> emit, State newState) {
    if (isClosed) {
      debugPrint('⚠️ safeEmit: BLoC fermé, état ignoré ($runtimeType)');
      return false;
    }
    emit(newState);
    return true;
  }
}
