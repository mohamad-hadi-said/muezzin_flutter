import 'package:flutter/material.dart';
import 'package:muezzin_flutter/core/error/exceptions.dart';
import 'package:muezzin_flutter/core/error/failures.dart';

/// A utility class for handling errors and displaying user-friendly messages.
class ErrorUtils {
  /// Converts an exception to a user-friendly error message.
  static String getErrorMessage(dynamic error) {
    if (error is CacheException) {
      return 'A caching error occurred: ${error.message}';
    } else if (error is ServerException) {
      return 'Server error: ${error.message}';
    } else if (error is NetworkException) {
      return 'Network error: ${error.message}';
    } else if (error is ValidationException) {
      return 'Validation error: ${error.message}';
    } else if (error is UnauthorizedException) {
      return 'Authentication required: ${error.message}';
    } else if (error is NotFoundException) {
      return 'Resource not found: ${error.message}';
    } else if (error is TimeoutException) {
      return 'Request timed out: ${error.message}';
    } else if (error is String) {
      return error;
    } else if (error is Error) {
      return 'An unexpected error occurred: ${error.toString()}';
    } else if (error is Exception) {
      return 'An exception occurred: ${error.toString()}';
    } else {
      return 'An unknown error occurred';
    }
  }

  /// Shows a snackbar with the error message.
  static void showErrorSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Shows a dialog with the error message.
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(buttonText),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Handles a failure by showing an error message.
  static void handleFailure(
    BuildContext context, 
    Failure failure, {
    bool showDialog = false,
  }) {
    final message = getErrorMessage(failure);
    
    if (showDialog) {
      showErrorDialog(
        context,
        title: 'Error',
        message: message,
      );
    } else {
      showErrorSnackBar(context, message: message);
    }
  }

  /// Executes the given function and handles any errors that occur.
  static Future<T?> handleError<T>(
    BuildContext context,
    Future<T> Function() function, {
    bool showDialog = false,
    T? Function(dynamic error)? onError,
  }) async {
    try {
      return await function();
    } catch (error) {
      if (onError != null) {
        return onError(error);
      }
      
      final message = getErrorMessage(error);
      
      if (showDialog) {
        await showErrorDialog(
          context,
          title: 'Error',
          message: message,
        );
      } else {
        showErrorSnackBar(context, message: message);
      }
      
      return null;
    }
  }
}
