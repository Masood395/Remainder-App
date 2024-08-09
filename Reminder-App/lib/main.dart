import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  initializeTimeZones(); // Initialize timezone data
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Reminder App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ReminderPage(),
    );
  }
}

class ReminderPage extends StatefulWidget {
  const ReminderPage({Key? key}) : super(key: key);

  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String _selectedDay = 'Monday';
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedActivity = 'Wake up';

  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final List<String> activities = [
    'Wake up',
    'Go to gym',
    'Breakfast',
    'Meetings',
    'Lunch',
    'Quick nap',
    'Go to library',
    'Dinner',
    'Go to sleep'
  ];

  @override
  void initState() {
    super.initState();
    initializeNotification();
  }

  void initializeNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request permissions for Android 13+ or older
    final bool? granted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
    if (granted ?? false) {
      debugPrint('Notification permissions granted');
    } else {
      debugPrint('Notification permissions denied');
    }
  }

  void scheduleNotification(TimeOfDay time, String activity) async {
    debugPrint(
        'Attempting to schedule notification for $activity at ${time.format(context)}');

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'reminder_channel_id',
      'Reminder Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final now = DateTime.now();
    tz.TZDateTime scheduledNotificationDateTime = tz.TZDateTime.from(
      DateTime(now.year, now.month, now.day, time.hour, time.minute),
      tz.local,
    );

    if (scheduledNotificationDateTime.isBefore(now)) {
      scheduledNotificationDateTime =
          scheduledNotificationDateTime.add(const Duration(days: 1));
    }

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Reminder',
        'It\'s time for $activity',
        scheduledNotificationDateTime,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('Notification scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/download.jpeg', // Ensure this file exists
              fit: BoxFit.cover, // Makes the image fit the entire background
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedDay,
                  onChanged: (String? newValue) {
                    setState(() {
                      if (newValue != null) {
                        _selectedDay = newValue;
                      }
                    });
                  },
                  items: daysOfWeek.map((day) {
                    return DropdownMenuItem<String>(
                      value: day,
                      child: Text(day),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Day of the Week',
                    filled: true, // Fill background for better visibility
                    fillColor: Colors.white70, // Semi-transparent background
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _selectTime(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Select Time',
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                      controller: TextEditingController(
                        text: _selectedTime.format(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedActivity,
                  onChanged: (String? newValue) {
                    setState(() {
                      if (newValue != null) {
                        _selectedActivity = newValue;
                      }
                    });
                  },
                  items: activities.map((activity) {
                    return DropdownMenuItem<String>(
                      value: activity,
                      child: Text(activity),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Activity',
                    filled: true,
                    fillColor: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    scheduleNotification(_selectedTime, _selectedActivity);
                  },
                  child: const Text('Set Reminder'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
