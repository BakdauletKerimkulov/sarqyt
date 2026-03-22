import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/items/presentation/item_create/item_image_picker_controller.dart';

class ItemImagePicker extends ConsumerWidget {
  const ItemImagePicker({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedImageValue = ref.watch(itemImagePickerControllerProvider(id));
    final productImagePickerController = ref.read(
      itemImagePickerControllerProvider(id).notifier,
    );
    return AsyncValueWidget(
      value: selectedImageValue,
      data: (selectedImage) {
        return AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(Sizes.p16),
            ),
            child: selectedImage != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Sizes.p16),
                        child: selectedImage.fold(
                          (file) => Image.file(file, fit: BoxFit.cover),
                          (bytes) => Image.memory(bytes, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: productImagePickerController.removeImage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            elevation: WidgetStatePropertyAll(5),
                          ),
                          onPressed: productImagePickerController.pickImage,
                          child: const Text('Change'),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: Sizes.p48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        gapH8,
                        ElevatedButton(
                          onPressed: productImagePickerController.pickImage,
                          child: const Text('Upload photo'),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
