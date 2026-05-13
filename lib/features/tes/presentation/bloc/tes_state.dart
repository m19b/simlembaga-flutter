import 'package:equatable/equatable.dart';
import '../../data/tes_model.dart';

abstract class TesState extends Equatable {
  const TesState();

  @override
  List<Object?> get props => [];
}

class TesInitial extends TesState {}

class TesLoading extends TesState {}

class TesRiwayatLoading extends TesState {}

class TesLoaded extends TesState {
  final List<CalonTes> calonTesList;

  const TesLoaded({
    required this.calonTesList,
  });

  @override
  List<Object?> get props => [calonTesList];
}

class TesRiwayatLoaded extends TesState {
  final List<RiwayatTes> riwayatList;
  final bool hasReachedMax;

  const TesRiwayatLoaded({
    required this.riwayatList,
    required this.hasReachedMax,
  });

  @override
  List<Object?> get props => [riwayatList, hasReachedMax];
}

class TesError extends TesState {
  final String message;

  const TesError(this.message);

  @override
  List<Object?> get props => [message];
}

class TesActionSuccess extends TesState {
  final String message;
  const TesActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
