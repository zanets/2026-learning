import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/http_header_service.dart';

class HttpHeaderState {
  final bool isLoading;
  final List<HttpHeaderResult> results;
  final String? error;

  const HttpHeaderState({
    this.isLoading = false,
    this.results = const [],
    this.error,
  });

  HttpHeaderState copyWith({
    bool? isLoading,
    List<HttpHeaderResult>? results,
    String? error,
    bool clearError = false,
  }) {
    return HttpHeaderState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class HttpHeaderNotifier extends FamilyNotifier<HttpHeaderState, String> {
  final _service = HttpHeaderService();

  @override
  HttpHeaderState build(String ip) => const HttpHeaderState();

  Future<void> fetch() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, results: [], clearError: true);
    try {
      final results = await _service.fetchAll(arg);
      state = state.copyWith(isLoading: false, results: results);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final httpHeaderProvider =
    NotifierProvider.family<HttpHeaderNotifier, HttpHeaderState, String>(
  HttpHeaderNotifier.new,
);
