import 'package:equatable/equatable.dart';
import 'package:manajemen_tahsin_app/features/catatan_master/data/catatan_master_model.dart';

abstract class CatatanMasterState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CatatanMasterInitial extends CatatanMasterState {}

class CatatanMasterLoading extends CatatanMasterState {}

class CatatanMasterLoaded extends CatatanMasterState {
  final List<CatatanMaster> catatan;
  final Map<String, dynamic> filterMeta;
  final String? message; // Untuk success feedback
  final bool isOfflineWarning;

  CatatanMasterLoaded({
    required this.catatan,
    required this.filterMeta,
    this.message,
    this.isOfflineWarning = false,
  });

  @override
  List<Object?> get props => [catatan, filterMeta, message, isOfflineWarning];

  CatatanMasterLoaded copyWith({
    List<CatatanMaster>? catatan,
    Map<String, dynamic>? filterMeta,
    String? message,
    bool? isOfflineWarning,
  }) {
    return CatatanMasterLoaded(
      catatan: catatan ?? this.catatan,
      filterMeta: filterMeta ?? this.filterMeta,
      message: message,
      isOfflineWarning: isOfflineWarning ?? this.isOfflineWarning,
    );
  }
}

class CatatanMasterError extends CatatanMasterState {
  final String message;
  CatatanMasterError(this.message);

  @override
  List<Object?> get props => [message];
}

class CatatanMasterActionProgress extends CatatanMasterState {
  final Map<String, dynamic> filterMeta;
  CatatanMasterActionProgress(this.filterMeta);

  @override
  List<Object?> get props => [filterMeta];
}
