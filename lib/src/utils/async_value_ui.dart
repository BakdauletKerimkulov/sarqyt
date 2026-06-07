import 'dart:async';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/exceptions/app_exception.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

/// A helper [AsyncValue] extension to show an alert dialog on error
extension AsyncValueUI on AsyncValue {
  void showAlertDialogOnError(BuildContext context) {
    if (!isLoading && hasError) {
      final message = humanReadableError(error);
      showExceptionAlertDialog(
        context: context,
        title: context.loc.error,
        exception: message,
      );
    }
  }
}

/// Translates any error into a human-readable message.
/// Single source of truth for all error messages in the app.
String humanReadableError(Object? error) {
  if (error is AppException) return error.message;

  // Firebase Auth
  if (error is FirebaseAuthException) {
    return _authErrorMessage(error.code);
  }

  // Cloud Functions
  if (error is FirebaseFunctionsException) {
    // CF often includes a readable message from our AppError
    if (error.message != null && error.message!.isNotEmpty) {
      return error.message!;
    }
    return _functionsErrorMessage(error.code);
  }

  // Firestore
  if (error is FirebaseException) {
    return _firestoreErrorMessage(error.code);
  }

  // Network
  if (error is SocketException) return 'No internet connection'.hardcoded;
  if (error is TimeoutException) {
    return 'Request timed out. Try again'.hardcoded;
  }

  // Fallback
  return 'Something went wrong. Try again'.hardcoded;
}

String _authErrorMessage(String code) {
  return switch (code) {
    'user-not-found' => 'User not found'.hardcoded,
    'wrong-password' => 'Wrong password'.hardcoded,
    'invalid-credential' => 'Invalid email or password'.hardcoded,
    'email-already-in-use' => 'Email already registered'.hardcoded,
    'weak-password' => 'Password too weak (min 6 characters)'.hardcoded,
    'invalid-email' => 'Invalid email address'.hardcoded,
    'too-many-requests' => 'Too many attempts. Try later'.hardcoded,
    'user-disabled' => 'This account has been disabled'.hardcoded,
    'operation-not-allowed' => 'Operation not allowed'.hardcoded,
    'requires-recent-login' => 'Please sign in again to continue'.hardcoded,
    _ => 'Authentication error. Try again'.hardcoded,
  };
}

String _functionsErrorMessage(String code) {
  return switch (code) {
    'unauthenticated' => 'Please sign in'.hardcoded,
    'not-found' => 'Not found'.hardcoded,
    'permission-denied' => 'Access denied'.hardcoded,
    'unavailable' => 'Service unavailable. Try later'.hardcoded,
    'invalid-argument' => 'Invalid input'.hardcoded,
    _ => 'Something went wrong. Try again'.hardcoded,
  };
}

String _firestoreErrorMessage(String code) {
  return switch (code) {
    'permission-denied' => 'Access denied'.hardcoded,
    'not-found' => 'Not found'.hardcoded,
    'unavailable' => 'No connection. Check internet'.hardcoded,
    'failed-precondition' => 'Operation failed. Try again'.hardcoded,
    _ => 'Something went wrong. Try again'.hardcoded,
  };
}
