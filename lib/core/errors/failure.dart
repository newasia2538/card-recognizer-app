import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

class ImagePickerFailure extends Failure {
  const ImagePickerFailure(super.message);
}
