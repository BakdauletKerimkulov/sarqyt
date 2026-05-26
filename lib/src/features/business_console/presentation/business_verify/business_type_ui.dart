import 'package:flutter/material.dart';
import 'package:sarqyt/l10n/app_localizations.dart';
import 'package:sarqyt/src/features/business_console/domain/business.dart';

extension BusinessTypeUiX on BusinessType {
  IconData get icon {
    return switch (this) {
      BusinessType.company => Icons.people,
      BusinessType.individual => Icons.person,
    };
  }

  String title(AppLocalizations loc) {
    return switch (this) {
      BusinessType.company => loc.company,
      BusinessType.individual => loc.individual,
    };
  }

  String description(AppLocalizations loc) {
    return switch (this) {
      BusinessType.company => loc.registeredEntity,
      BusinessType.individual => loc.individualOrSole,
    };
  }
}
