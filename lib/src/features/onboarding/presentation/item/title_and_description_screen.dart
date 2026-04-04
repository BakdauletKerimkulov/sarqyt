import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/utils/auth_layout.dart';
import 'package:sarqyt/src/features/items/presentation/item_create/item_draft_controller.dart';
import 'package:sarqyt/src/features/onboarding/presentation/onboarding_panel.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/business_router.dart';

class TitleAndDescriptionScreen extends StatelessWidget {
  const TitleAndDescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      startBackground: 'assets/sarqyt_item.png',
      child: OnboardingPanel(
        title: 'Name the title and description',
        onBackPressed: () => context.pop(),
        child: TitleAndDescriptionContent(),
      ),
    );
  }
}

class TitleAndDescriptionContent extends ConsumerStatefulWidget {
  const TitleAndDescriptionContent({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TitleAndDescriptionContentState();
}

class _TitleAndDescriptionContentState
    extends ConsumerState<TitleAndDescriptionContent> {
  final _form = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    final itemDraft = ref.read(itemDraftControllerProvider);
    _titleController.text = itemDraft.title;
    _descriptionController.text = itemDraft.description;
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String get title => _titleController.text;
  String get description => _descriptionController.text;

  bool _submitted = false;

  void submit() {
    setState(() => _submitted = true);

    if (_form.currentState!.validate()) {
      ref
          .read(itemDraftControllerProvider.notifier)
          .saveTitleAndDescription(title, description);
    }
  }

  String? titleValidator(String value) {
    return value.isEmpty ? 'Title cannot be empty' : null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Title'.hardcoded),
          gapH4,
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(border: OutlineInputBorder()),
            maxLength: 25,
            validator: (value) =>
                !_submitted ? null : titleValidator(value ?? ''),
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          gapH16,
          Text('Description'.hardcoded),
          gapH4,
          TextField(
            maxLines: 3,
            maxLength: 100,
            controller: _descriptionController,
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
          gapH24,
          PrimaryWebButton(
            text: 'Continue'.hardcoded,
            onPressed: () {
              submit();
              context.pushNamed(BusinessRoute.priceAndStock.name);
            },
          ),
        ],
      ),
    );
  }
}
