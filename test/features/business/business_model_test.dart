import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/features/business_console/domain/business.dart';
import 'package:sarqyt/src/features/business_console/domain/business_verification_draft.dart';

void main() {
  group('Business.isConfirmed', () {
    Business makeBusiness({
      VerificationStatus status = VerificationStatus.unverified,
    }) {
      return Business(
        id: 'b1',
        ownerId: 'u1',
        name: 'Test Business',
        commissionRate: 0.15,
        createdAt: DateTime(2026, 1, 1),
        verificationStatus: status,
      );
    }

    test('true when verified', () {
      final b = makeBusiness(status: VerificationStatus.verified);
      expect(b.isConfirmed, true);
    });

    test('false when unverified', () {
      final b = makeBusiness(status: VerificationStatus.unverified);
      expect(b.isConfirmed, false);
    });

    test('false when submitted', () {
      final b = makeBusiness(status: VerificationStatus.submitted);
      expect(b.isConfirmed, false);
    });

    test('false when rejected', () {
      final b = makeBusiness(status: VerificationStatus.rejected);
      expect(b.isConfirmed, false);
    });
  });

  group('CompanyVerificationDraft.isComplete', () {
    test('complete when bin is set', () {
      const draft = CompanyVerificationDraft(bin: '123456789012');
      expect(draft.isComplete, true);
    });

    test('incomplete when bin is null', () {
      const draft = CompanyVerificationDraft(companyName: 'Acme');
      expect(draft.isComplete, false);
    });

    test('incomplete when bin is empty', () {
      const draft = CompanyVerificationDraft(bin: '');
      expect(draft.isComplete, false);
    });

    test('incomplete when bin is whitespace', () {
      const draft = CompanyVerificationDraft(bin: '   ');
      expect(draft.isComplete, false);
    });
  });

  group('IndividualVerificationDraft.isComplete', () {
    IndividualVerificationDraft fullIndividual() {
      return const IndividualVerificationDraft(
        iin: '123456789012',
        dateOfBirth: '1990-01-01',
        firstName: 'John',
        lastName: 'Doe',
        addressLine1: '123 Main St',
        postalCode: '010000',
        city: 'Astana',
        region: 'Astana',
        country: 'KZ',
      );
    }

    test('complete when all required fields set', () {
      expect(fullIndividual().isComplete, true);
    });

    test('incomplete without iin', () {
      final draft = fullIndividual().copyWith(iin: null);
      expect(draft.isComplete, false);
    });

    test('incomplete without firstName', () {
      final draft = fullIndividual().copyWith(firstName: null);
      expect(draft.isComplete, false);
    });

    test('incomplete with empty city', () {
      final draft = fullIndividual().copyWith(city: '');
      expect(draft.isComplete, false);
    });

    test('incomplete with whitespace-only region', () {
      final draft = fullIndividual().copyWith(region: '  ');
      expect(draft.isComplete, false);
    });
  });

  group('BusinessVerificationDraft', () {
    test('hasCompletedRequiredFields delegates to company draft', () {
      const draft = BusinessVerificationDraft(
        businessType: BusinessType.company,
        company: CompanyVerificationDraft(bin: '123456789012'),
      );
      expect(draft.hasCompletedRequiredFields, true);
    });

    test('hasCompletedRequiredFields false for incomplete company', () {
      const draft = BusinessVerificationDraft(
        businessType: BusinessType.company,
        company: CompanyVerificationDraft(),
      );
      expect(draft.hasCompletedRequiredFields, false);
    });

    test('hasCompletedRequiredFields delegates to individual draft', () {
      const draft = BusinessVerificationDraft(
        businessType: BusinessType.individual,
        individual: IndividualVerificationDraft(
          iin: '123456789012',
          dateOfBirth: '1990-01-01',
          firstName: 'John',
          lastName: 'Doe',
          addressLine1: '123 Main St',
          postalCode: '010000',
          city: 'Astana',
          region: 'Astana',
          country: 'KZ',
        ),
      );
      expect(draft.hasCompletedRequiredFields, true);
    });

    test('activeCompanyDraft returns company when type is company', () {
      const draft = BusinessVerificationDraft(
        businessType: BusinessType.company,
      );
      expect(draft.activeCompanyDraft, isNotNull);
      expect(draft.activeIndividualDraft, isNull);
    });

    test(
      'activeIndividualDraft returns individual when type is individual',
      () {
        const draft = BusinessVerificationDraft(
          businessType: BusinessType.individual,
        );
        expect(draft.activeCompanyDraft, isNull);
        expect(draft.activeIndividualDraft, isNotNull);
      },
    );
  });
}
