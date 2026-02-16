import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_client/email_password_sign_in_form_type.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_client/email_password_sign_in_screen.dart';
import 'package:sarqyt/src/features/checkout/presentation/payment_page.dart';
import 'package:sarqyt/src/features/products/domain/product.dart';

enum CheckoutSubRoute { register, payment }

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.productID});

  final ProductID productID;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  late final PageController _controller;

  var _subRoute = CheckoutSubRoute.register;

  @override
  void initState() {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      setState(() {
        _subRoute = CheckoutSubRoute.payment;
      });
    }
    _controller = PageController(initialPage: _subRoute.index);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSignedIn() {
    setState(() {
      _subRoute = CheckoutSubRoute.payment;
    });

    _controller.animateToPage(
      _subRoute.index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInExpo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _subRoute == CheckoutSubRoute.payment
        ? 'Payment'
        : 'Register';

    final productId = widget.productID;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _controller,
        children: [
          EmailPasswordSignInContent(
            formType: EmailPasswordSignInFormType.register,
            onSignedIn: _onSignedIn,
          ),
          PaymentPage(productID: productId),
        ],
      ),
    );
  }
}
