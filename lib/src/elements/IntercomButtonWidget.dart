import 'dart:async';
import 'package:flutter/material.dart';
import '../helpers/intercom_helper.dart';
import '../../generated/l10n.dart';

class IntercomButtonWidget extends StatefulWidget {
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final String? tooltip;

  const IntercomButtonWidget({
    super.key,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.tooltip,
  });

  @override
  State<IntercomButtonWidget> createState() => _IntercomButtonWidgetState();
}

class _IntercomButtonWidgetState extends State<IntercomButtonWidget> {
  bool _hasUnreadMessages = false;
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();
    _checkUnreadMessages();
    _startPeriodicCheck();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicCheck() {
    _checkTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkUnreadMessages();
    });
  }

  Future<void> _checkUnreadMessages() async {
    try {
      final hasUnread = await IntercomHelper.hasUnreadConversations();
      if (mounted && hasUnread != _hasUnreadMessages) {
        setState(() {
          _hasUnreadMessages = hasUnread;
        });
      }
    } catch (e) {
      debugPrint('Error checking unread messages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: widget.size ?? 56,
          height: widget.size ?? 56,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Theme.of(context).primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(widget.size ?? 56),
              onTap: () async {
                try {
                  await IntercomHelper.displayMessenger();
                  // إعادة فحص الرسائل غير المقروءة بعد فتح المساعد
                  _checkUnreadMessages();
                } catch (e) {
                  // إظهار رسالة خطأ للمستخدم
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to load chat support. Please check your internet connection.',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              child: Icon(
                Icons.support_agent,
                color: widget.iconColor ?? Colors.white,
                size: (widget.size ?? 56) * 0.4,
              ),
            ),
          ),
        ),
        if (_hasUnreadMessages)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Center(
                child: Text(
                  '!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class IntercomFloatingButton extends StatelessWidget {
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final String? tooltip;

  const IntercomFloatingButton({
    super.key,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        await IntercomHelper.displayMessenger();
      },
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      tooltip: tooltip ?? S.of(context).contact_support_intercom,
      child: Icon(
        Icons.support_agent,
        color: iconColor ?? Colors.white,
      ),
    );
  }
}

class IntercomHelpButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onPressed;

  const IntercomHelpButton({
    super.key,
    this.text,
    this.icon,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed ?? () async {
        await IntercomHelper.displayHelpCenter();
      },
      icon: Icon(icon ?? Icons.help_outline),
      label: Text(text ?? S.of(context).intercom_help),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
