import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/features/offers/presentation/home_app_bar/home_app_bar.dart';
import 'package:sarqyt/src/features/offers/presentation/offers_list_screen/sliver_offers_list.dart';
import 'package:sarqyt/src/routing/app_router.dart';

class OffersListScreen extends StatefulWidget {
  const OffersListScreen({super.key});

  @override
  State<OffersListScreen> createState() => _OffersListScreenState();
}

class _OffersListScreenState extends State<OffersListScreen> {
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(),
      body: CustomScrollView(
        controller: _controller,
        slivers: [
          SliverOffersGrid(
            onPressed: (context, id) => context.goNamed(
              AppRoute.offer.name,
              pathParameters: {'id': id},
            ),
          ),
        ],
      ),
    );
  }
}
