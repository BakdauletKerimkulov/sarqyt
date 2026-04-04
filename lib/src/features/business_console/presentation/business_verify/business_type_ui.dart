import 'package:flutter/material.dart';
import 'package:sarqyt/src/features/business_console/domain/business.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

extension BusinessTypeUiX on BusinessType {
  IconData get icon {
    return switch (this) {
      BusinessType.company => Icons.people,
      BusinessType.individual => Icons.person,
    };
  }

  String get title {
    return switch (this) {
      BusinessType.company => 'Company'.hardcoded,
      BusinessType.individual => 'Individual'.hardcoded,
    };
  }

  String get description {
    return switch (this) {
      BusinessType.company => 'A registered business entity'.hardcoded,
      BusinessType.individual => 'An individual or sole proprietor'.hardcoded,
    };
  }
}
