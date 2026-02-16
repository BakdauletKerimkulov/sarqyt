import 'package:flutter/material.dart';

enum StoreType {
  cafe(label: 'Cafe', icon: Icons.coffee),
  restaurant(label: 'Restaurant', icon: Icons.palette),
  bakery(label: 'Bakery', icon: Icons.bakery_dining),
  supermarket(label: 'Supermarket', icon: Icons.shopping_bag);

  final String label;
  final IconData icon;

  const StoreType({required this.label, required this.icon});
}
