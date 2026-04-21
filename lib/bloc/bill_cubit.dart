import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/bill_scenario.dart';
import '../models/bills_section.dart';
import '../services/bill_repository.dart';

enum BillStatus { initial, loading, loaded, error }

class BillState {
  const BillState({
    required this.status,
    required this.selectedScenario,
    this.section,
    this.errorMessage,
  });

  const BillState.initial()
    : status = BillStatus.initial,
      selectedScenario = BillScenario.manyItems,
      section = null,
      errorMessage = null;

  final BillStatus status;
  final BillScenario selectedScenario;
  final BillsSection? section;
  final String? errorMessage;

  BillState copyWith({
    BillStatus? status,
    BillScenario? selectedScenario,
    BillsSection? section,
    String? errorMessage,
    bool clearSection = false,
    bool clearError = false,
  }) {
    return BillState(
      status: status ?? this.status,
      selectedScenario: selectedScenario ?? this.selectedScenario,
      section: clearSection ? null : section ?? this.section,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class BillCubit extends Cubit<BillState> {
  BillCubit(this._repository) : super(const BillState.initial());

  final BillRepository _repository;

  Future<void> load([BillScenario? scenario]) async {
    final selectedScenario = scenario ?? state.selectedScenario;
    emit(
      state.copyWith(
        status: BillStatus.loading,
        selectedScenario: selectedScenario,
        clearError: true,
      ),
    );

    try {
      final section = await _repository.fetchSection(selectedScenario);
      emit(
        state.copyWith(
          status: BillStatus.loaded,
          selectedScenario: selectedScenario,
          section: section,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: BillStatus.error,
          selectedScenario: selectedScenario,
          errorMessage:
              'We could not load the bills feed. Please retry the mock API.',
        ),
      );
    }
  }
}
