import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../database/database_helper.dart';
import 'profile_page.dart';
import 'poem_details_page.dart';

class NotificationsPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const NotificationsPage({Key? key, required this.user}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 20;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _page = 1;
        _hasMore = true;
        _notifications.clear();
      });
    }

    if (!_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final notifications = await _dbHelper.getNotifications(
        widget.user['id'],
        limit: _limit,
        offset: (_page - 1) * _limit,
      );

      if (mounted) {
        setState(() {
          _notifications.addAll(notifications);
          _hasMore = notifications.length == _limit;
          _page++;
          _isLoading = false;
        });
      }

      // Mark notifications as read
      await _dbHelper.markNotificationsAsRead(widget.user['id']);
    } catch (e) {
      print('Error loading notifications: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Notifications',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadNotifications(refresh: true),
        child: _notifications.isEmpty && !_isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: _notifications.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _notifications.length) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final notification = _notifications[index];
                  return _buildNotificationTile(notification);
                },
              ),
      ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    IconData icon;
    String message;
    Color? iconColor;

    switch (notification['type']) {
      case 'like':
        icon = Icons.favorite;
        message = 'liked your poem';
        iconColor = Colors.red;
        break;
      case 'comment':
        icon = Icons.comment;
        message = 'commented on your poem';
        iconColor = Colors.blue;
        break;
      case 'follow':
        icon = Icons.person;
        message = 'started following you';
        iconColor = Colors.green;
        break;
      default:
        icon = Icons.notifications;
        message = 'interacted with your content';
        iconColor = Colors.grey;
    }

    return InkWell(
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        decoration: BoxDecoration(
          color: notification['is_read'] == 0
              ? Colors.blue.withOpacity(0.1)
              : null,
        ),
        child: ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundImage: notification['user_image'] != null
                    ? NetworkImage(notification['user_image'])
                    : null,
                child: notification['user_image'] == null
                    ? Text(notification['username'][0].toUpperCase())
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          title: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                  text: notification['username'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' '),
                TextSpan(text: message),
                if (notification['target_title'] != null) ...[
                  TextSpan(text: ' '),
                  TextSpan(
                    text: notification['target_title'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ),
          subtitle: Text(
            timeago.format(DateTime.parse(notification['created_at'])),
            style: TextStyle(color: Colors.grey),
          ),
          trailing: notification['is_read'] == 0
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Future<void> _handleNotificationTap(Map<String, dynamic> notification) async {
    switch (notification['type']) {
      case 'follow':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(
              user: {'id': notification['user_id']},
            ),
          ),
        );
        break;
      case 'like':
      case 'comment':
        if (notification['target_id'] != null) {
          final poem = await _dbHelper.getPoem(notification['target_id']);
          if (poem != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PoemDetailsPage(
                  poem: poem,
                  currentUser: widget.user,
                ),
              ),
            );
          }
        }
        break;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
