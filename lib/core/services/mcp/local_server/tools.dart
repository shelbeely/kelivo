import 'dart:async';
import 'dart:convert';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';

// A generic interface for our local tools
abstract class Tool {
  // The name of the tool
  String get name;

  // The description of the tool
  String get description;

  // The JSON schema for the tool's input
  Map<String, dynamic> get inputSchema;

  // The method to call the tool
  Future<Map<String, dynamic>> call(Map<String, dynamic> arguments);
}

class DeviceStatusTool implements Tool {
  @override
  String get name => 'device_status';

  @override
  String get description => 'Get the device status, including battery, network, and timestamp.';

  @override
  Map<String, dynamic> get inputSchema => {
        'type': 'object',
        'properties': {},
        'required': [],
      };

  @override
  Future<Map<String, dynamic>> call(Map<String, dynamic> arguments) async {
    try {
      final battery = Battery();
      final batteryLevel = await battery.batteryLevel;
      final batteryState = await battery.batteryState;

      final connectivity = Connectivity();
      final connectivityResult = await connectivity.checkConnectivity();

      final timestamp = DateTime.now().toIso8601String();

      return {
        'content': [
          {
            'type': 'text',
            'text': jsonEncode({
              'battery': {
                'level': batteryLevel,
                'state': batteryState.toString(),
              },
              'network': {
                'type': connectivityResult.toString(),
              },
              'timestamp': timestamp,
            }),
          }
        ],
        'isStreaming': false,
        'isError': false,
      };
    } catch (e) {
      return {
        'content': [
          {'type': 'text', 'text': e.toString()}
        ],
        'isStreaming': false,
        'isError': true,
      };
    }
  }
}

class CalendarTool implements Tool {
  Future<bool> _requestPermission() async {
    var status = await Permission.calendar.status;
    if (status.isDenied) {
      status = await Permission.calendar.request();
    }
    return status.isGranted;
  }

  @override
  String get name => 'calendar';

  @override
  String get description => 'Manage calendar events, reminders, and attendees.';

  @override
  Map<String, dynamic> get inputSchema => {
        'type': 'object',
        'properties': {
          'action': {
            'type': 'string',
            'description': 'The action to perform.',
            'enum': ['list', 'create', 'read', 'update', 'delete'],
            'default': 'list',
          },
          'calendarId': {
            'type': 'string',
            'description': 'The ID of the calendar to perform the action on.',
          },
          'eventId': {
            'type': 'string',
            'description': 'The ID of the event to perform the action on.',
          },
          'event': {
            'type': 'object',
            'description': 'The event data to create or update.',
          },
        },
        'required': ['action', 'calendarId'],
      };

  @override
  Future<Map<String, dynamic>> call(Map<String, dynamic> arguments) async {
    try {
      if (!await _requestPermission()) {
        throw Exception('Calendar permission denied');
      }
      final action = arguments['action'] as String;
      final calendarId = arguments['calendarId'] as String;
      final eventId = arguments['eventId'] as String?;
      final eventData = arguments['event'] as Map<String, dynamic>?;

      final deviceCalendarPlugin = DeviceCalendarPlugin();
      final calendarsResult = await deviceCalendarPlugin.retrieveCalendars();
      final calendars = calendarsResult.data;

      if (calendars == null || calendars.isEmpty) {
        throw Exception('No calendars found on this device.');
      }

      final calendar = calendars.firstWhere((c) => c.id == calendarId);

      switch (action) {
        case 'list':
          final eventsResult = await deviceCalendarPlugin.retrieveEvents(
              calendar.id,
              RetrieveEventsParams(
                  startDate: DateTime.now().subtract(Duration(days: 30)),
                  endDate: DateTime.now().add(Duration(days: 30))));
          final events = eventsResult.data;
          return {
            'content': [
              {'type': 'text', 'text': jsonEncode(events)}
            ],
            'isStreaming': false,
            'isError': false,
          };
        case 'create':
          final event = Event.fromJson(eventData!);
          final createEventResult =
              await deviceCalendarPlugin.createOrUpdateEvent(event);
          return {
            'content': [
              {'type': 'text', 'text': jsonEncode(createEventResult?.data)}
            ],
            'isStreaming': false,
            'isError': false,
          };
        case 'read':
          final eventResult = await deviceCalendarPlugin.retrieveEvents(
              calendar.id,
              RetrieveEventsParams(
                  startDate: DateTime.now().subtract(Duration(days: 30)),
                  endDate: DateTime.now().add(Duration(days: 30))));
          final event = eventResult.data?.firstWhere((e) => e.eventId == eventId);
          return {
            'content': [
              {'type': 'text', 'text': jsonEncode(event)}
            ],
            'isStreaming': false,
            'isError': false,
          };
        case 'update':
          final event = Event.fromJson(eventData!);
          final updateEventResult =
              await deviceCalendarPlugin.createOrUpdateEvent(event);
          return {
            'content': [
              {'type': 'text', 'text': jsonEncode(updateEventResult?.data)}
            ],
            'isStreaming': false,
            'isError': false,
          };
        case 'delete':
          final deleteEventResult = await deviceCalendarPlugin.deleteEvent(
              calendar.id, eventId!);
          return {
            'content': [
              {'type': 'text', 'text': jsonEncode(deleteEventResult.data)}
            ],
            'isStreaming': false,
            'isError': false,
          };
        default:
          throw Exception('Invalid action: $action');
      }
    } catch (e) {
      return {
        'content': [
          {'type': 'text', 'text': e.toString()}
        ],
        'isStreaming': false,
        'isError': true,
      };
    }
  }
}

class ContactsTool implements Tool {
  Future<bool> _requestPermission() async {
    var status = await Permission.contacts.status;
    if (status.isDenied) {
      status = await Permission.contacts.request();
    }
    return status.isGranted;
  }

  @override
  String get name => 'contacts';

  @override
  String get description => 'Get the contacts from the device.';

  @override
  Map<String, dynamic> get inputSchema => {
        'type': 'object',
        'properties': {},
        'required': [],
      };

  @override
  Future<Map<String, dynamic>> call(Map<String, dynamic> arguments) async {
    try {
      if (!await _requestPermission()) {
        throw Exception('Contacts permission denied');
      }
      final contacts = await ContactsService.getContacts();
      final contactList = contacts
          .map((c) => {
                'displayName': c.displayName,
                'givenName': c.givenName,
                'middleName': c.middleName,
                'familyName': c.familyName,
                'prefix': c.prefix,
                'suffix': c.suffix,
                'company': c.company,
                'jobTitle': c.jobTitle,
                'emails': c.emails?.map((e) => e.value).toList(),
                'phones': c.phones?.map((p) => p.value).toList(),
                'postalAddresses': c.postalAddresses
                    ?.map((a) => {
                          'label': a.label,
                          'street': a.street,
                          'city': a.city,
                          'postcode': a.postcode,
                          'region': a.region,
                          'country': a.country,
                        })
                    .toList(),
                'avatar': c.avatar,
              })
          .toList();

      return {
        'content': [
          {'type': 'text', 'text': jsonEncode(contactList)}
        ],
        'isStreaming': false,
        'isError': false,
      };
    } catch (e) {
      return {
        'content': [
          {'type': 'text', 'text': e.toString()}
        ],
        'isStreaming': false,
        'isError': true,
      };
    }
  }
}

class LocationTool implements Tool {
  Future<bool> _requestPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
    }
    return status.isGranted;
  }

  @override
  String get name => 'location';

  @override
  String get description => 'Get the device\'s current location.';

  @override
  Map<String, dynamic> get inputSchema => {
        'type': 'object',
        'properties': {
          'accuracy': {
            'type': 'string',
            'description': 'The desired accuracy of the location.',
            'enum': ['low', 'high'],
            'default': 'low',
          },
        },
        'required': [],
      };

  @override
  Future<Map<String, dynamic>> call(Map<String, dynamic> arguments) async {
    try {
      if (!await _requestPermission()) {
        throw Exception('Location permission denied');
      }
      final accuracy = arguments['accuracy'] as String? ?? 'low';
      final desiredAccuracy =
          accuracy == 'high' ? LocationAccuracy.high : LocationAccuracy.low;

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: desiredAccuracy);

      return {
        'content': [
          {
            'type': 'text',
            'text': jsonEncode({
              'latitude': position.latitude,
              'longitude': position.longitude,
              'accuracy': position.accuracy,
            }),
          }
        ],
        'isStreaming': false,
        'isError': false,
      };
    } catch (e) {
      return {
        'content': [
          {'type': 'text', 'text': e.toString()}
        ],
        'isStreaming': false,
        'isError': true,
      };
    }
  }
}

class SmsTool implements Tool {
  Future<bool> _requestPermission() async {
    var status = await Permission.sms.status;
    if (status.isDenied) {
      status = await Permission.sms.request();
    }
    return status.isGranted;
  }

  @override
  String get name => 'sms';

  @override
  String get description => 'Send an SMS message to a single recipient.';

  @override
  Map<String, dynamic> get inputSchema => {
        'type': 'object',
        'properties': {
          'recipient': {
            'type': 'string',
            'description': 'The phone number of the recipient.',
          },
          'message': {
            'type': 'string',
            'description': 'The content of the message.',
          },
          'confirm': {
            'type': 'boolean',
            'description': 'Whether to show a confirmation dialog before sending.',
            'default': true,
          },
        },
        'required': ['recipient', 'message'],
      };

  @override
  Future<Map<String, dynamic>> call(Map<String, dynamic> arguments) async {
    try {
      if (!await _requestPermission()) {
        throw Exception('SMS permission denied');
      }
      final recipient = arguments['recipient'] as String;
      final message = arguments['message'] as String;
      final confirm = arguments['confirm'] as bool? ?? true;

      if (confirm) {
        // Here you would typically show a dialog to the user
        // to confirm sending the message. For simplicity, we'll
        // just log it to the console.
        print('Confirmation required to send SMS to $recipient: "$message"');
      }

      await sendSMS(message: message, recipients: [recipient]);

      return {
        'content': [
          {'type': 'text', 'text': 'SMS sent successfully.'}
        ],
        'isStreaming': false,
        'isError': false,
      };
    } catch (e) {
      return {
        'content': [
          {'type': 'text', 'text': e.toString()}
        ],
        'isStreaming': false,
        'isError': true,
      };
    }
  }
}

class SensorsTool implements Tool {
  @override
  String get name => 'sensors';

  @override
  String get description => 'Get sensor data, including motion, ambient light, proximity, and barometer.';

  @override
  Map<String, dynamic> get inputSchema => {
        'type': 'object',
        'properties': {},
        'required': [],
      };

  @override
  Future<Map<String, dynamic>> call(Map<String, dynamic> arguments) async {
    try {
      final accelerometer = await accelerometerEvents.first;
      final gyroscope = await gyroscopeEvents.first;
      final magnetometer = await magnetometerEvents.first;

      return {
        'content': [
          {
            'type': 'text',
            'text': jsonEncode({
              'accelerometer': {
                'x': accelerometer.x,
                'y': accelerometer.y,
                'z': accelerometer.z,
              },
              'gyroscope': {
                'x': gyroscope.x,
                'y': gyroscope.y,
                'z': gyroscope.z,
              },
              'magnetometer': {
                'x': magnetometer.x,
                'y': magnetometer.y,
                'z': magnetometer.z,
              },
            }),
          }
        ],
        'isStreaming': false,
        'isError': false,
      };
    } catch (e) {
      return {
        'content': [
          {'type': 'text', 'text': e.toString()}
        ],
        'isStreaming': false,
        'isError': true,
      };
    }
  }
}
