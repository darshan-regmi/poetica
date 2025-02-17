import 'package:flutter/material.dart';
import 'dart:async';
import 'database/database_helper.dart';
import 'pages/poem_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:math' show min;
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'pages/profile_page.dart';
import 'pages/create_page.dart';
import 'pages/notifications_page.dart';
import 'package:flutter/material.dart' show BuildContext;

// Add this class at the top level (outside of any other class)
class Comment {
  final String username;
  final String text;
  final DateTime timestamp;
  bool isLiked;
  int likeCount;

  Comment({
    required this.username,
    required this.text,
    required this.timestamp,
    this.isLiked = false,
    this.likeCount = 0,
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(PoeticaApp());
}

class PoeticaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poetica',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, dynamic>? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      // For demo, we'll create a default user if none exists
      final users = await _dbHelper.getUsers();
      if (users.isEmpty) {
        final userId = await _dbHelper.createUser({
          'username': 'demo_user',
          'email': 'demo@example.com',
          'password_hash': 'demo_hash',
          'created_at': DateTime.now().toIso8601String(),
        });
        _currentUser = await _dbHelper.getUser(userId);
      } else {
        _currentUser = users.first;
      }
    } catch (e) {
      print('Error checking auth: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_currentUser == null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error loading user data'),
          ),
        ),
      );
    }

    return PoeticaHome(user: _currentUser!);
  }
}

class PoeticaHome extends StatefulWidget {
  final Map<String, dynamic> user;

  const PoeticaHome({Key? key, required this.user}) : super(key: key);

  @override
  _PoeticaHomeState createState() => _PoeticaHomeState();
}

class _PoeticaHomeState extends State<PoeticaHome> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _initPages();
    _checkNotifications();
  }

  void _initPages() {
    _pages = [
      HomePage(user: widget.user),
      SearchPage(user: widget.user),
      Container(), // Placeholder for FAB
      NotificationsPage(user: widget.user),
      ProfilePage(user: widget.user),
    ];
  }

  Future<void> _checkNotifications() async {
    try {
      final count =
          await _dbHelper.getUnreadNotificationsCount(widget.user['id']);
      setState(() => _unreadNotifications = count);
    } catch (e) {
      print('Error checking notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePage(user: widget.user),
            ),
          );
          if (result == true) {
            // Refresh the current page if a poem was created
            setState(() {
              _initPages();
            });
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home),
            _buildNavItem(1, Icons.search),
            SizedBox(width: 48), // Space for FAB
            Stack(
              children: [
                _buildNavItem(3, Icons.notifications),
                if (_unreadNotifications > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _unreadNotifications.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            _buildNavItem(4, Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    return IconButton(
      icon: Icon(icon),
      color: _currentIndex == index ? Colors.blue : Colors.grey,
      onPressed: () {
        setState(() => _currentIndex = index);
        if (index == 3) {
          setState(() => _unreadNotifications = 0);
        }
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _poems = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPoems();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadPoems({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _page = 1;
        _hasMore = true;
        _poems.clear();
      });
    }

    if (!_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final poems = await _dbHelper.getForYouPoems(
        widget.user['id'],
        limit: _limit,
        offset: (_page - 1) * _limit,
      );

      setState(() {
        _poems.addAll(poems);
        _hasMore = poems.length == _limit;
        _page++;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading poems: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadPoems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('For You'),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadPoems(refresh: true),
        child: _poems.isEmpty && !_isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_stories,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No poems yet',
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
                itemCount: _poems.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _poems.length) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final poem = _poems[index];
                  return PoemCard(
                    poem: poem,
                    currentUser: widget.user,
                    onPoemUpdated: () => _loadPoems(refresh: true),
                  );
                },
              ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class SearchPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const SearchPage({Key? key, required this.user}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String _searchType = 'poems'; // or 'users'

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() => _searchResults.clear());
    } else {
      _performSearch(_searchController.text);
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);

    try {
      final results = _searchType == 'poems'
          ? await _dbHelper.searchPoems(query, widget.user['id'])
          : await _dbHelper.searchUsers(query, widget.user['id']);

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Error performing search: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search ${_searchType == 'poems' ? 'poems' : 'users'}...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _searchType = value;
                _searchController.clear();
                _searchResults.clear();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'poems',
                child: Text('Search Poems'),
              ),
              PopupMenuItem(
                value: 'users',
                child: Text('Search Users'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _searchResults.isEmpty
              ? Center(
                  child: Text(
                    _searchController.text.isEmpty
                        ? 'Search for poems or users'
                        : 'No results found',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return _searchType == 'poems'
                        ? PoemCard(
                            poem: result,
                            currentUser: widget.user,
                            onPoemUpdated: () =>
                                _performSearch(_searchController.text),
                          )
                        : ListTile(
                            leading: CircleAvatar(
                              backgroundImage: result['profile_picture'] != null
                                  ? NetworkImage(result['profile_picture'])
                                  : null,
                              child: result['profile_picture'] == null
                                  ? Text(result['username'][0].toUpperCase())
                                  : null,
                            ),
                            title: Text(result['username']),
                            subtitle: Text(
                              '${result['followers_count']} followers',
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProfilePage(user: result),
                                ),
                              );
                            },
                          );
                  },
                ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class PoemCard extends StatefulWidget {
  final Map<String, dynamic> poem;
  final Map<String, dynamic> currentUser;
  final VoidCallback onPoemUpdated;

  const PoemCard({
    Key? key,
    required this.poem,
    required this.currentUser,
    required this.onPoemUpdated,
  }) : super(key: key);

  @override
  _PoemCardState createState() => _PoemCardState();
}

class _PoemCardState extends State<PoemCard> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> _toggleLike() async {
    try {
      await _dbHelper.toggleLike(
        widget.currentUser['id'],
        widget.poem['id'],
      );
      widget.onPoemUpdated();
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  Future<void> _toggleSave() async {
    try {
      await _dbHelper.toggleSave(
        widget.currentUser['id'],
        widget.poem['id'],
      );
      widget.onPoemUpdated();
    } catch (e) {
      print('Error toggling save: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      user: {
                        'id': widget.poem['author_id'],
                        'username': widget.poem['author_name'],
                        'profile_picture': widget.poem['author_image'],
                      },
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: widget.poem['author_image'] != null
                    ? NetworkImage(widget.poem['author_image'])
                    : null,
                child: widget.poem['author_image'] == null
                    ? Text(widget.poem['author_name'][0].toUpperCase())
                    : null,
              ),
            ),
            title: Text(widget.poem['author_name']),
            subtitle: Text(
              DateFormat.yMMMd().format(
                DateTime.parse(widget.poem['created_at']),
              ),
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                if (widget.poem['author_id'] == widget.currentUser['id']) ...[
                  PopupMenuItem(
                    child: Text('Edit'),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreatePage(
                            user: widget.currentUser,
                            poemToEdit: widget.poem,
                          ),
                        ),
                      );
                      widget.onPoemUpdated();
                    },
                  ),
                  PopupMenuItem(
                    child: Text('Delete'),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete Poem'),
                          content: Text(
                            'Are you sure you want to delete this poem?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _dbHelper.deletePoem(widget.poem['id']);
                        widget.onPoemUpdated();
                      }
                    },
                  ),
                ],
                PopupMenuItem(
                  child: Text('Report'),
                  onTap: () {
                    // Implement report functionality
                  },
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PoemDetailsPage(
                    poem: widget.poem,
                    currentUser: widget.currentUser,
                  ),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.poem['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.poem['content'],
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  widget.poem['is_liked'] == 1
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: widget.poem['is_liked'] == 1 ? Colors.red : null,
                ),
                onPressed: _toggleLike,
              ),
              IconButton(
                icon: Icon(Icons.comment_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PoemDetailsPage(
                        poem: widget.poem,
                        currentUser: widget.currentUser,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  widget.poem['is_saved'] == 1
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: widget.poem['is_saved'] == 1 ? Colors.blue : null,
                ),
                onPressed: _toggleSave,
              ),
              IconButton(
                icon: Icon(Icons.share_outlined),
                onPressed: () {
                  // Implement share functionality
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    // Validate inputs
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _dbHelper.loginUser(username, password);

      if (user != null) {
        // Save user login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', user['id']);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainApp(user: user)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid username or password')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              enabled: !_isLoading,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                border: OutlineInputBorder(),
              ),
              obscureText: _obscurePassword,
              enabled: !_isLoading,
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Text('Login'),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
              child: Text('Don\'t have an account? Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(hintText: 'Username'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(hintText: 'Email'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(hintText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String username = _usernameController.text;
                String password = _passwordController.text;
                String email = _emailController.text;

                if (username.isNotEmpty && password.isNotEmpty) {
                  await _dbHelper.registerUser(username, password, email);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('User registered successfully'),
                  ));
                  Navigator.pop(context);
                }
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  final Map<String, dynamic> user;
  const NotificationsPage({required this.user});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await _dbHelper.getNotifications(widget.user['id']);
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
      setState(() => _isLoading = false);
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
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: _notifications.isEmpty
                  ? Center(
                      child: Text(
                        'No notifications yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _notifications.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildNewSection();
                        }
                        return _buildNotificationItem(
                            _notifications[index - 1]);
                      },
                    ),
            ),
    );
  }

  Widget _buildNewSection() {
    final newNotifications =
        _notifications.where((n) => !n['is_read']).toList();
    if (newNotifications.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'New',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: newNotifications.length,
          itemBuilder: (context, index) => _buildNotificationItem(
            newNotifications[index],
            isNew: true,
          ),
        ),
        Divider(height: 32),
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Earlier',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification,
      {bool isNew = false}) {
    return InkWell(
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        color: isNew ? Colors.blue.withOpacity(0.1) : null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildNotificationAvatar(notification),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: notification['username'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: ' ${notification['message']}'),
                          if (notification['target_title'] != null)
                            TextSpan(
                              text: ' "${notification['target_title']}"',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatTimestamp(notification['created_at']),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              _buildNotificationAction(notification),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationAvatar(Map<String, dynamic> notification) {
    return CircleAvatar(
      radius: 24,
      backgroundImage: notification['user_image'] != null
          ? NetworkImage(notification['user_image'])
          : null,
      child: notification['user_image'] == null
          ? Text(notification['username'][0].toUpperCase())
          : null,
    );
  }

  Widget _buildNotificationAction(Map<String, dynamic> notification) {
    switch (notification['type']) {
      case 'follow':
        return OutlinedButton(
          onPressed: () => _toggleFollow(notification['user_id']),
          child: Text(
            notification['is_following'] == 1 ? 'Following' : 'Follow',
          ),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      case 'like':
      case 'comment':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: notification['target_preview'] != null
              ? Image.network(
                  notification['target_preview'],
                  fit: BoxFit.cover,
                )
              : Icon(Icons.book_outlined),
        );
      default:
        return SizedBox.shrink();
    }
  }

  String _formatTimestamp(String timestamp) {
    final now = DateTime.now();
    final date = DateTime.parse(timestamp);
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat('MMMM d').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }

  Future<void> _toggleFollow(int userId) async {
    try {
      await _dbHelper.toggleFollow(widget.user['id'], userId);
      _loadNotifications();
    } catch (e) {
      print('Error toggling follow: $e');
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PoemDetailsPage(
                title: notification['target_title'],
                content: notification['target_content'],
                poetName: notification['target_author'],
                genre: notification['target_genre'],
                isPublished: true,
              ),
            ),
          );
        }
        break;
    }
  }
}

class CommentTile extends StatelessWidget {
  final Map<String, dynamic> comment;

  const CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: comment['user_image'] != null
            ? NetworkImage(comment['user_image'])
            : null,
        child: comment['user_image'] == null
            ? Text(comment['username'][0].toUpperCase())
            : null,
      ),
      title: Text(comment['username']),
      subtitle: Text(comment['content']),
      trailing: Text(
        DateFormat.yMMMd().format(DateTime.parse(comment['created_at'])),
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}

class CommentInput extends StatefulWidget {
  final Function(String) onSubmit;

  const CommentInput({required this.onSubmit});

  @override
  _CommentInputState createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                widget.onSubmit(_controller.text);
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
