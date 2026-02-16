import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/products/domain/product.dart';
import 'package:sarqyt/src/features/products/domain/product_from_data.dart';
import 'package:sarqyt/src/features/store/domain/store.dart';

part 'products_repoitory.g.dart';

class ProductsRepoitory {
  const ProductsRepoitory(this._firestore);
  final FirebaseFirestore _firestore;

  static String productsPath(StoreID storeId) => 'stores/$storeId/products';
  static String productPath(StoreID storeId, ProductID id) =>
      'stores/$storeId/products/$id';

  Future<List<Product>> fetchProductsList(StoreID storeId) async {
    final ref = _productsRef(storeId);
    final snapshot = await ref.get();
    return snapshot.docs.map((snapshot) => snapshot.data()).toList();
  }

  Stream<List<Product>> watchProductsList(StoreID storeId) {
    final ref = _productsRef(storeId);
    return ref.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((docSnapshot) => docSnapshot.data()).toList(),
    );
  }

  Future<Product?> fetchProduct(StoreID storeId, ProductID id) async {
    final ref = _productRef(storeId, id);
    final snapshot = await ref.get();
    return snapshot.data();
  }

  Stream<Product?> watchProduct(StoreID storeId, ProductID id) {
    final ref = _productRef(storeId, id);
    return ref.snapshots().map((snapshot) => snapshot.data());
  }

  Future<void> createProduct(
    StoreID storeId, {
    required ProductFromData product,
  }) {
    final docRef = _firestore.collection(productsPath(storeId)).doc();
    final finalProduct = Product(
      id: docRef.id,
      name: product.name,
      price: product.price,
      description: product.description,
      packagingOption: product.packagingOption,
      imageUrl: product.imageUrl,
    );
    return docRef.set(finalProduct.toFirestore());
  }

  Future<void> updateProduct(StoreID storeId, {required Product product}) {
    return _productRef(storeId, product.id).set(product);
  }

  Future<void> deleteProduct(StoreID storeId, {required ProductID id}) {
    return _firestore.doc(productPath(storeId, id)).delete();
  }

  DocumentReference<Product> _productRef(StoreID storeId, ProductID id) =>
      _firestore
          .doc(productPath(storeId, id))
          .withConverter(
            fromFirestore: (doc, _) => Product.fromMap(doc.data()!),
            toFirestore: (Product product, options) => product.toMap(),
          );

  Query<Product> _productsRef(StoreID storeId) => _firestore
      .collection(productsPath(storeId))
      .withConverter(
        fromFirestore: (doc, _) => Product.fromMap(doc.data()!),
        toFirestore: (Product product, options) => product.toMap(),
      )
      .orderBy('id');
}

@Riverpod(keepAlive: true)
ProductsRepoitory productsRepoitory(Ref ref) {
  return ProductsRepoitory(FirebaseFirestore.instance);
}

@riverpod
Stream<List<Product>> productsListStream(Ref ref, StoreID storeId) {
  final repo = ref.watch(productsRepoitoryProvider);
  return repo.watchProductsList(storeId);
}

@riverpod
Stream<Product?> productStream(
  Ref ref, {
  required StoreID storeId,
  required ProductID id,
}) {
  final repo = ref.watch(productsRepoitoryProvider);
  return repo.watchProduct(storeId, id);
}
