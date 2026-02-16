// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/constants/breakpoints.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_client/string_validators.dart';
import 'package:sarqyt/src/features/products/domain/money.dart';
import 'package:sarqyt/src/features/products/domain/product_from_data.dart';
import 'package:sarqyt/src/features/products/presentation/create_product_controller.dart';
import 'package:sarqyt/src/features/products/presentation/product_image_picker.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class CreateProductScreen extends ConsumerWidget {
  const CreateProductScreen({super.key, required this.storeId});

  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      createProductControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    final selectedImage = ref.watch(productImagePickerControllerProvider).value;

    final state = ref.watch(createProductControllerProvider);
    final isLoading = state.isLoading;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: CreateProductContent(
          isLoading: isLoading,
          onConfirm: (product) {
            ref
                .read(createProductControllerProvider.notifier)
                .createProduct(product, storeId: storeId, image: selectedImage);
          },
        ),
      ),
    );
  }
}

class CreateProductContent extends StatefulWidget {
  const CreateProductContent({
    super.key,
    required this.onConfirm,
    required this.isLoading,
  });

  final bool isLoading;
  final void Function(ProductFromData)? onConfirm;

  @override
  State<CreateProductContent> createState() => _CreateProductContentState();
}

class _CreateProductContentState extends State<CreateProductContent>
    with CreateProductValidator {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _packaginOptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _packaginOptionController.dispose();
    super.dispose();
  }

  void submit() {
    if (_formKey.currentState!.validate()) {
      final product = ProductFromData(
        name: _nameController.text,
        description: _descriptionController.text,
        packagingOption: _packaginOptionController.text,
        price: Money(
          code: _currency.code,
          amount: double.parse(_priceController.text),
          currency: _currency.symbol,
        ),
      );
      widget.onConfirm?.call(product);
    }
  }

  Currency _currency = Currency.kzt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // * Заголовок
        Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back),
            ),
            Text(
              'Create a new product',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        gapH16,

        // * Форма заполнения
        Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // * Основная информация
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Product name',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    gapH4,
                    TextFormField(
                      readOnly: widget.isLoading,
                      controller: _nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Sizes.p16),
                        ),
                        helperText: '',
                      ),
                      maxLength: 20,
                      validator: (value) => errorText(value ?? ''),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    gapH8,
                    Text(
                      'Description (optional)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    gapH4,
                    TextField(
                      readOnly: widget.isLoading,
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Sizes.p16),
                        ),
                        helperText: '',
                      ),
                      maxLength: 100,
                    ),

                    gapH8,
                    Text(
                      'Packaging Option (optional)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    gapH4,
                    TextField(
                      readOnly: widget.isLoading,
                      controller: _packaginOptionController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Sizes.p16),
                        ),
                        helperText: '',
                      ),
                    ),
                    gapH8,
                    Text(
                      'Price',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            readOnly: widget.isLoading,
                            controller: _priceController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Sizes.p16),
                              ),
                              helperText: '',
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) => errorText(value ?? ''),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                        ),
                        gapW16,
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: 90,
                            maxWidth: 100,
                          ),
                          child: DropdownButtonFormField<Currency>(
                            onTap: null,
                            initialValue: _currency,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Sizes.p16),
                              ),
                              helperText: '',
                            ),
                            items: Currency.values.map((cur) {
                              return DropdownMenuItem<Currency>(
                                value: cur,
                                child: Text(cur.code),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _currency = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              gapW40,

              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add photo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    gapH4,
                    ConstrainedBox(
                      constraints: BoxConstraints(minWidth: Breakpoint.mobile),
                      child: ProductImagePicker(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        gapH24,

        PrimaryWebButton(
          width: 400.0,
          text: 'Save product'.hardcoded,
          isLoading: widget.isLoading,
          onPressed: submit,
        ),

        const SizedBox(height: 100.0),
      ],
    );
  }
}

mixin CreateProductValidator {
  final StringValidator nonEmptyValidator = NonEmptyStringValidator();

  bool canSubmitted(String value) {
    return nonEmptyValidator.isValid(value);
  }

  String? errorText(String value) {
    final bool showErrorText = !canSubmitted(value);
    final String errorText = 'Field can\'t be empty';
    return showErrorText ? errorText : null;
  }
}
