import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mycomicsapp/core/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart'; 

class DailyReminderSwitch extends StatefulWidget {
  const DailyReminderSwitch({super.key});

  @override
  State<DailyReminderSwitch> createState() => _DailyReminderSwitchState();
}

class _DailyReminderSwitchState extends State<DailyReminderSwitch> {
  bool _isEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0); 

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isEnabled = prefs.getBool('daily_reminder_enabled') ?? false;
      final hour = prefs.getInt('daily_reminder_hour') ?? 20;
      final minute = prefs.getInt('daily_reminder_minute') ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _toggleReminder(bool value) async {
    if (value) {
      final status = await Permission.notification.request();
      
      if (status.isDenied || status.isPermanentlyDenied) {
        // Nếu bị từ chối, hiển thị thông báo hướng dẫn người dùng vào cài đặt
        if (mounted) {
          _showPermissionDialog();
        }
        return; 
      }
    }

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isEnabled = value;
    });
    
    await prefs.setBool('daily_reminder_enabled', value);

    if (value) {
      await _scheduleNotification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reminder set for ${_reminderTime.format(context)} daily!')),
        );
      }
    } else {
      await NotificationService().cancelNotification(100); 
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text('To receive daily reading reminders, please allow notifications in settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings(); // Mở trang cài đặt của ứng dụng
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );

    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('daily_reminder_hour', picked.hour);
      await prefs.setInt('daily_reminder_minute', picked.minute);

      if (_isEnabled) {
        await _scheduleNotification();
      }
    }
  }

  Future<void> _scheduleNotification() async {
    await NotificationService().scheduleDailyNotification(
      id: 100,
      title: "It's reading time! 🌙",
      body: "Take a break and enjoy your favorite comics.",
      time: _reminderTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Daily Reading Reminder'),
          subtitle: Text(_isEnabled 
            ? 'Scheduled at ${_reminderTime.format(context)}' 
            : 'Get notified to read every day'),
          value: _isEnabled,
          onChanged: _toggleReminder,
          secondary: Icon(
            _isEnabled ? Icons.notifications_active : Icons.notifications_off,
            color: _isEnabled ? Theme.of(context).colorScheme.primary : Colors.grey,
          ),
        ),
        if (_isEnabled)
          ListTile(
            title: const Text('Change Time'),
            leading: const Icon(Icons.access_time),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _pickTime,
          ),
      ],
    );
  }
}