import 'package:flutter/material.dart';
import 'dart:async';
import 'database_helper.dart';

void main() {
  runApp(PoeticaApp());
}

class PoeticaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Poetica',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
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
              controller: _passwordController,
              decoration: InputDecoration(hintText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String username = _usernameController.text;
                String password = _passwordController.text;

                final user = await _dbHelper.loginUser(username, password);
                if (username.isNotEmpty && password.isNotEmpty) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PoeticaHome(user: user)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Invalid username or password'),
                  ));
                }
              },
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
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

class PoeticaHome extends StatefulWidget {
  final Map<String, dynamic> user;

  PoeticaHome({required this.user});

  @override
  _PoeticaHomeState createState() => _PoeticaHomeState();
}

class _PoeticaHomeState extends State<PoeticaHome> {
  int _currentIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ExplorePage(),
      CreatePoemPage(),
      NotificationsPage(),
      ProfilePage(username: widget.user['username']),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Poetica',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Serif',
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
// Search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
// Notifications functionality
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.explore,
                color: Colors.black,
              ),
              label: 'Explore'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.edit,
                color: Colors.black,
              ),
              label: 'Create'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.notifications,
                color: Colors.black,
              ),
              label: 'Alerts'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color: Colors.black,
              ),
              label: 'Profile'),
        ],
      ),
    );
  }
}

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _poems = [];

  @override
  void initState() {
    super.initState();
    _fetchPoems();
  }

  Future<void> _fetchPoems() async {
    final poems = await _dbHelper.getPoems();
    setState(() {
      _poems = poems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _poems.isEmpty
        ? Center(child: Text('No poems yet.'))
        : ListView.builder(
            itemCount: _poems.length,
            itemBuilder: (context, index) {
              final poem = _poems[index];
              return PoemCard(
                title: poem['title'],
                content: poem['content'],
              );
            },
          );
  }
}

class PoemCard extends StatelessWidget {
  final String title;
  final String content;

  PoemCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poem Header
            ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    NetworkImage('https://via.placeholder.com/150'),
              ),
              title: Text('Poet Name',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Mood: Reflective'),
              trailing: Icon(Icons.more_vert),
            ),
            // Poem Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreatePoemPage extends StatefulWidget {
  @override
  _CreatePoemPageState createState() => _CreatePoemPageState();
}

class _CreatePoemPageState extends State<CreatePoemPage> {
  final TextEditingController _poemTitleController = TextEditingController();
  final TextEditingController _poemContentController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a Poem'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _poemTitleController,
              decoration: InputDecoration(
                hintText: 'Enter poem title...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _poemContentController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Write your poem here...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                String title = _poemTitleController.text;
                String content = _poemContentController.text;

                if (title.isNotEmpty && content.isNotEmpty) {
                  await _dbHelper.insertPoem(title, content);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Poem saved!'),
                  ));
                  _poemTitleController.clear();
                  _poemContentController.clear();
                }
              },
              child: Text('Save Poem'),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  final List<Map<String, String>> _notifications = [
    {"title": "New Like", "body": "Alice liked your poem 'Blood’s Call'."},
    {"title": "New Follower", "body": "John Doe started following you."},
    {"title": "New Comment", "body": "Bob commented: 'Amazing work!'"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        centerTitle: true,
      ),
      body: _notifications.isEmpty
          ? Center(child: Text('No notifications yet.'))
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return ListTile(
                  leading: Icon(Icons.notifications, color: Colors.blue),
                  title: Text(notification['title']!),
                  subtitle: Text(notification['body']!),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
// Handle notification tap
                  },
                );
              },
            ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final String username; // Pass the username of the logged-in user

  const ProfilePage({Key? key, required this.username}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = await _dbHelper.database.then((db) => db.query(
            'users',
            where: 'username = ?',
            whereArgs: [widget.username],
            limit: 1,
          ));

      if (user.isNotEmpty) {
        setState(() {
          _userData = user.first;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _logout() {
    Navigator.of(context)
        .pushReplacementNamed('/login'); // Navigate to login page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: _userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                        'assets/user_avatar.png'), // Replace with actual avatar logic if needed
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _userData?['username'] ?? 'N/A',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _userData?['email'] ?? 'N/A',
                    style: const TextStyle(
                        fontSize: 18, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _logout,
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
    );
  }
}
