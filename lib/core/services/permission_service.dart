import 'package:card_recognizer/core/constants/permission_constants.dart';
import 'package:card_recognizer/presentation/widgets/request_permission_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionService {
  // Request Camera Permission
  static Future<bool> requestCamera(BuildContext context) async {
    final status = await Permission.camera.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied && context.mounted) {
      _showSettingsDialog(
        context,
        title: PermissionConstants.cameraRequiredTitle,
        message: PermissionConstants.cameraRequiredMessage,
        icon: Icons.camera_alt,
      );
      return false;
    }

    return false;
  }

  // Request Gallery Permission
  static Future<bool> requestGallery(BuildContext context) async {
    final status = await Permission.photos.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await Permission.photos.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied && context.mounted) {
      _showSettingsDialog(
        context,
        title: PermissionConstants.galleryRequiredTitle,
        message: PermissionConstants.galleryRequiredMessage,
        icon: Icons.photo_library,
      );
      return false;
    }

    return false;
  }

  // Settings Dialog for Permanently Denied
  static void _showSettingsDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => PermissionEducationDialog(
            description: message,
            title: title,
            icon: icon,
            onProceed: () => openAppSettings(),
          ),
    );
  }
}
