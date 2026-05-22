import 'package:equatable/equatable.dart';

abstract class InitialSyncState extends Equatable {
  const InitialSyncState();

  @override
  List<Object?> get props => [];
}

class InitialSyncInitial extends InitialSyncState {}

class InitialSyncInProgress extends InitialSyncState {
  final double progress;
  final String message;

  const InitialSyncInProgress(this.progress, this.message);

  @override
  List<Object?> get props => [progress, message];
}

class InitialSyncSuccess extends InitialSyncState {
  final String message;

  const InitialSyncSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class InitialSyncFailure extends InitialSyncState {
  final String error;

  const InitialSyncFailure(this.error);

  @override
  List<Object?> get props => [error];
}
