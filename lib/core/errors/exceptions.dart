class PermissionException implements Exception {
  final String message;
  const PermissionException(this.message);
}

class ImagePickerException implements Exception {
  final String message;
  const ImagePickerException(this.message);
}
