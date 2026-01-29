import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/support/domain/entities/contact_info.dart';

void main() {
  group('ContactInfo', () {
    group('constructor', () {
      test('should create ContactInfo with all required fields', () {
        final contactInfo = ContactInfo(
          phone: '+22670000000',
          phoneDisplay: '70 00 00 00',
          email: 'support@ouagachap.com',
          whatsapp: '+22670000000',
          whatsappMessage: 'Bonjour, je souhaite...',
          workingHours: const WorkingHours(
            days: 'Lundi - Samedi',
            hours: '08:00 - 18:00',
          ),
          social: const SocialLinks(
            facebook: 'https://facebook.com/ouagachap',
            instagram: 'https://instagram.com/ouagachap',
            twitter: 'https://twitter.com/ouagachap',
          ),
          address: const Address(
            street: '123 Avenue de la Paix',
            city: 'Ouagadougou',
            country: 'Burkina Faso',
          ),
        );

        expect(contactInfo.phone, '+22670000000');
        expect(contactInfo.phoneDisplay, '70 00 00 00');
        expect(contactInfo.email, 'support@ouagachap.com');
        expect(contactInfo.whatsapp, '+22670000000');
        expect(contactInfo.whatsappMessage, 'Bonjour, je souhaite...');
      });
    });

    group('fromJson', () {
      test('should create ContactInfo from complete JSON', () {
        final json = {
          'phone': '+22670111111',
          'phone_display': '70 11 11 11',
          'email': 'contact@test.com',
          'whatsapp': '+22670222222',
          'whatsapp_message': 'Hello',
          'working_hours': {
            'days': 'Mon - Fri',
            'hours': '09:00 - 17:00',
          },
          'social': {
            'facebook': 'https://fb.com/test',
            'instagram': 'https://ig.com/test',
            'twitter': 'https://tw.com/test',
          },
          'address': {
            'street': '456 Test Street',
            'city': 'Test City',
            'country': 'Test Country',
          },
        };

        final contactInfo = ContactInfo.fromJson(json);

        expect(contactInfo.phone, '+22670111111');
        expect(contactInfo.phoneDisplay, '70 11 11 11');
        expect(contactInfo.email, 'contact@test.com');
        expect(contactInfo.whatsapp, '+22670222222');
        expect(contactInfo.whatsappMessage, 'Hello');
      });

      test('should handle missing values with defaults', () {
        final json = <String, dynamic>{};

        final contactInfo = ContactInfo.fromJson(json);

        expect(contactInfo.phone, '');
        expect(contactInfo.phoneDisplay, '');
        expect(contactInfo.email, '');
        expect(contactInfo.whatsapp, '');
        expect(contactInfo.whatsappMessage, '');
      });
    });

    group('Equatable', () {
      test('props should contain phone, email, whatsapp, workingHours, social, address', () {
        const workingHours = WorkingHours(days: 'Mon-Fri', hours: '9-5');
        const social = SocialLinks(facebook: 'fb', instagram: 'ig', twitter: 'tw');
        const address = Address(street: 'St', city: 'City', country: 'Country');
        
        final contactInfo = ContactInfo(
          phone: '+226',
          phoneDisplay: '226',
          email: 'test@test.com',
          whatsapp: '+226',
          whatsappMessage: 'msg',
          workingHours: workingHours,
          social: social,
          address: address,
        );

        expect(contactInfo.props, ['+226', 'test@test.com', '+226', workingHours, social, address]);
      });
    });
  });

  group('WorkingHours', () {
    group('constructor', () {
      test('should create WorkingHours', () {
        const workingHours = WorkingHours(
          days: 'Lundi - Samedi',
          hours: '08:00 - 18:00',
        );

        expect(workingHours.days, 'Lundi - Samedi');
        expect(workingHours.hours, '08:00 - 18:00');
      });
    });

    group('fromJson', () {
      test('should create WorkingHours from JSON', () {
        final json = {
          'days': 'Mon - Fri',
          'hours': '09:00 - 17:00',
        };

        final workingHours = WorkingHours.fromJson(json);

        expect(workingHours.days, 'Mon - Fri');
        expect(workingHours.hours, '09:00 - 17:00');
      });

      test('should handle missing values', () {
        final json = <String, dynamic>{};

        final workingHours = WorkingHours.fromJson(json);

        expect(workingHours.days, '');
        expect(workingHours.hours, '');
      });
    });

    group('Equatable', () {
      test('props should contain days and hours', () {
        const workingHours = WorkingHours(days: 'Mon', hours: '9-5');
        expect(workingHours.props, ['Mon', '9-5']);
      });

      test('two WorkingHours with same values should be equal', () {
        const wh1 = WorkingHours(days: 'Mon-Fri', hours: '9-5');
        const wh2 = WorkingHours(days: 'Mon-Fri', hours: '9-5');
        expect(wh1, equals(wh2));
      });
    });
  });

  group('SocialLinks', () {
    group('constructor', () {
      test('should create SocialLinks', () {
        const social = SocialLinks(
          facebook: 'https://facebook.com/test',
          instagram: 'https://instagram.com/test',
          twitter: 'https://twitter.com/test',
        );

        expect(social.facebook, 'https://facebook.com/test');
        expect(social.instagram, 'https://instagram.com/test');
        expect(social.twitter, 'https://twitter.com/test');
      });
    });

    group('fromJson', () {
      test('should create SocialLinks from JSON', () {
        final json = {
          'facebook': 'fb_url',
          'instagram': 'ig_url',
          'twitter': 'tw_url',
        };

        final social = SocialLinks.fromJson(json);

        expect(social.facebook, 'fb_url');
        expect(social.instagram, 'ig_url');
        expect(social.twitter, 'tw_url');
      });

      test('should handle missing values', () {
        final json = <String, dynamic>{};

        final social = SocialLinks.fromJson(json);

        expect(social.facebook, '');
        expect(social.instagram, '');
        expect(social.twitter, '');
      });
    });

    group('Equatable', () {
      test('props should contain facebook, instagram, twitter', () {
        const social = SocialLinks(facebook: 'fb', instagram: 'ig', twitter: 'tw');
        expect(social.props, ['fb', 'ig', 'tw']);
      });

      test('two SocialLinks with same values should be equal', () {
        const s1 = SocialLinks(facebook: 'fb', instagram: 'ig', twitter: 'tw');
        const s2 = SocialLinks(facebook: 'fb', instagram: 'ig', twitter: 'tw');
        expect(s1, equals(s2));
      });
    });
  });

  group('Address', () {
    group('constructor', () {
      test('should create Address', () {
        const address = Address(
          street: '123 Main Street',
          city: 'Ouagadougou',
          country: 'Burkina Faso',
        );

        expect(address.street, '123 Main Street');
        expect(address.city, 'Ouagadougou');
        expect(address.country, 'Burkina Faso');
      });
    });

    group('fromJson', () {
      test('should create Address from JSON', () {
        final json = {
          'street': '456 Test Ave',
          'city': 'Bobo-Dioulasso',
          'country': 'Burkina Faso',
        };

        final address = Address.fromJson(json);

        expect(address.street, '456 Test Ave');
        expect(address.city, 'Bobo-Dioulasso');
        expect(address.country, 'Burkina Faso');
      });

      test('should handle missing values', () {
        final json = <String, dynamic>{};

        final address = Address.fromJson(json);

        expect(address.street, '');
        expect(address.city, '');
        expect(address.country, '');
      });
    });

    group('fullAddress', () {
      test('should return formatted full address', () {
        const address = Address(
          street: '123 Avenue de la Paix',
          city: 'Ouagadougou',
          country: 'Burkina Faso',
        );

        expect(address.fullAddress, '123 Avenue de la Paix, Ouagadougou, Burkina Faso');
      });

      test('should handle empty values in full address', () {
        const address = Address(street: '', city: '', country: '');
        expect(address.fullAddress, ', , ');
      });
    });

    group('Equatable', () {
      test('props should contain street, city, country', () {
        const address = Address(street: 'St', city: 'City', country: 'Country');
        expect(address.props, ['St', 'City', 'Country']);
      });

      test('two Addresses with same values should be equal', () {
        const a1 = Address(street: '123', city: 'Ouaga', country: 'BF');
        const a2 = Address(street: '123', city: 'Ouaga', country: 'BF');
        expect(a1, equals(a2));
      });

      test('two Addresses with different values should not be equal', () {
        const a1 = Address(street: '123', city: 'Ouaga', country: 'BF');
        const a2 = Address(street: '456', city: 'Bobo', country: 'BF');
        expect(a1, isNot(equals(a2)));
      });
    });
  });
}
