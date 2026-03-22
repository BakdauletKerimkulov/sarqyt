import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sarqyt/src/features/map/application/store_location_controller.dart';
import 'package:sarqyt/src/features/map/data/map_repository.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/store_draft_controller.dart';
import 'package:sarqyt/src/features/store/domain/country.dart';
import 'package:sarqyt/src/features/store/domain/store_type.dart';

/// Fake MapRepository, возвращает фиксированные координаты на основе query.
class FakeMapRepository extends MapRepository {
  final List<String> queries = [];

  @override
  Future<LatLng?> getCoordinates(String query) async {
    queries.add(query);
    // Возвращаем разные координаты в зависимости от содержимого query
    if (query.contains('Алматы')) {
      return const LatLng(43.2380, 76.9450);
    }
    if (query.contains('Астана')) {
      return const LatLng(51.1694, 71.4491);
    }
    return null;
  }
}

ProviderContainer createContainer({required FakeMapRepository fakeMapRepo}) {
  final container = ProviderContainer(
    overrides: [mapRepositoryProvider.overrideWithValue(fakeMapRepo)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('storeLocationProvider', () {
    test('returns null when draft has no address data', () async {
      final fakeMapRepo = FakeMapRepository();
      final container = createContainer(fakeMapRepo: fakeMapRepo);

      // Draft пустой — нет данных для координат
      final result = await container.read(storeLocationProvider.future);

      expect(result, isNull);
      expect(fakeMapRepo.queries, isEmpty);
    });

    test('fetches coordinates when draft has address data', () async {
      final fakeMapRepo = FakeMapRepository();
      final container = createContainer(fakeMapRepo: fakeMapRepo);

      // Заполняем draft
      container
          .read(storeDraftControllerProvider.notifier)
          .saveStepOne(
            name: 'Sarqyt',
            storeType: StoreType.cafe,
            address: 'Проспект Гагарина 124',
            postalCode: '050000',
            locality: 'Алматы',
            country: const CountryD(isoCode: 'KAZ', name: 'Казахстан'),
            phoneNumber: '+77771112233',
          );

      final result = await container.read(storeLocationProvider.future);

      expect(result, const LatLng(43.2380, 76.9450));
      expect(fakeMapRepo.queries, hasLength(1));
      expect(fakeMapRepo.queries.first, contains('Алматы'));
    });

    test('returns cached location from draft without fetching', () async {
      final fakeMapRepo = FakeMapRepository();
      final container = createContainer(fakeMapRepo: fakeMapRepo);

      // Draft уже содержит location
      container
          .read(storeDraftControllerProvider.notifier)
          .saveStepOne(
            name: 'Sarqyt',
            storeType: StoreType.cafe,
            address: 'Проспект Гагарина 124',
            postalCode: '050000',
            locality: 'Алматы',
            country: const CountryD(isoCode: 'KAZ', name: 'Казахстан'),
            phoneNumber: '+77771112233',
          );
      container
          .read(storeDraftControllerProvider.notifier)
          .saveLocation(const LatLng(43.0, 77.0));

      final result = await container.read(storeLocationProvider.future);

      // Должен вернуть location из draft, не делая запрос
      expect(result, const LatLng(43.0, 77.0));
      expect(fakeMapRepo.queries, isEmpty);
    });

    test('re-fetches when address changes', () async {
      final fakeMapRepo = FakeMapRepository();
      final container = createContainer(fakeMapRepo: fakeMapRepo);

      // Первый адрес
      container
          .read(storeDraftControllerProvider.notifier)
          .saveStepOne(
            name: 'Sarqyt',
            storeType: StoreType.cafe,
            address: 'Проспект Гагарина 124',
            postalCode: '050000',
            locality: 'Алматы',
            country: const CountryD(isoCode: 'KAZ', name: 'Казахстан'),
            phoneNumber: '+77771112233',
          );

      final result1 = await container.read(storeLocationProvider.future);
      expect(result1, const LatLng(43.2380, 76.9450));

      // Меняем адрес — saveStepOne сбрасывает location
      container
          .read(storeDraftControllerProvider.notifier)
          .saveStepOne(
            name: 'Sarqyt',
            storeType: StoreType.cafe,
            address: 'Улица Кенесары 40',
            postalCode: '010000',
            locality: 'Астана',
            country: const CountryD(isoCode: 'KAZ', name: 'Казахстан'),
            phoneNumber: '+77771112233',
          );

      // Invalidate чтобы provider перечитал draft
      container.invalidate(storeLocationProvider);
      final result2 = await container.read(storeLocationProvider.future);

      expect(result2, const LatLng(51.1694, 71.4491));
      expect(fakeMapRepo.queries, hasLength(2));
      expect(fakeMapRepo.queries.last, contains('Астана'));
    });

    test('saveStepOne resets location when address changes', () {
      final fakeMapRepo = FakeMapRepository();
      final container = createContainer(fakeMapRepo: fakeMapRepo);

      container
          .read(storeDraftControllerProvider.notifier)
          .saveStepOne(
            name: 'Sarqyt',
            storeType: StoreType.cafe,
            address: 'Проспект Гагарина 124',
            postalCode: '050000',
            locality: 'Алматы',
            country: const CountryD(isoCode: 'KAZ', name: 'Казахстан'),
            phoneNumber: '+77771112233',
          );
      container
          .read(storeDraftControllerProvider.notifier)
          .saveLocation(const LatLng(43.0, 77.0));

      final draft1 = container.read(storeDraftControllerProvider);
      expect(draft1.location, isNotNull);

      // Меняем адрес — location должен сброситься
      container
          .read(storeDraftControllerProvider.notifier)
          .saveStepOne(
            name: 'Sarqyt',
            storeType: StoreType.cafe,
            address: 'Новый адрес',
            postalCode: '050000',
            locality: 'Алматы',
            country: const CountryD(isoCode: 'KAZ', name: 'Казахстан'),
            phoneNumber: '+77771112233',
          );

      final draft2 = container.read(storeDraftControllerProvider);
      expect(draft2.location, isNull);
    });

    test('saveStepOne preserves location when address unchanged', () {
      final fakeMapRepo = FakeMapRepository();
      final container = createContainer(fakeMapRepo: fakeMapRepo);

      container
          .read(storeDraftControllerProvider.notifier)
          .saveStepOne(
            name: 'Sarqyt',
            storeType: StoreType.cafe,
            address: 'Проспект Гагарина 124',
            postalCode: '050000',
            locality: 'Алматы',
            country: const CountryD(isoCode: 'KAZ', name: 'Казахстан'),
            phoneNumber: '+77771112233',
          );
      container
          .read(storeDraftControllerProvider.notifier)
          .saveLocation(const LatLng(43.0, 77.0));

      // Тот же адрес, только имя изменилось
      container
          .read(storeDraftControllerProvider.notifier)
          .saveStepOne(
            name: 'Sarqyt Updated',
            storeType: StoreType.cafe,
            address: 'Проспект Гагарина 124',
            postalCode: '050000',
            locality: 'Алматы',
            country: const CountryD(isoCode: 'KAZ', name: 'Казахстан'),
            phoneNumber: '+77771112233',
          );

      final draft = container.read(storeDraftControllerProvider);
      expect(draft.location, const LatLng(43.0, 77.0));
    });
  });
}
