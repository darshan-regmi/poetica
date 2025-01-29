import 'package:flutter/material.dart';
import 'dart:async';
import 'database_helper.dart';
import 'poem_details_page.dart';

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
  List<Map<String, dynamic>> poems = []; // Declare poems

  @override
  void initState() {
    super.initState();
    _fetchPoems(); // Fetch poems when app starts

    final loggedInUserId = widget.user['id'];
    _pages = [
      ExplorePage(poems: poems), // Pass poems to ExplorePage
      CreatePoemPage(userId: loggedInUserId),
      NotificationsPage(),
      ProfilePage(username: widget.user['username']),
    ];
  }

  Future<void> _fetchPoems() async {
    final dbHelper = DatabaseHelper();
    final fetchedPoems = await dbHelper.getPoemsWithDetails();

    setState(() {
      poems = fetchedPoems;
    });

    print("Poems fetched: $poems");
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
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: _pages[_currentIndex], // Display the current page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.explore, color: Colors.black), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.edit, color: Colors.black), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications, color: Colors.black), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person, color: Colors.black), label: 'Profile'),
        ],
      ),
    );
  }
}

class ExplorePage extends StatefulWidget {
  final List<Map<String, dynamic>> poems;

  ExplorePage({required this.poems}); // Accept poems

  @override
  Future<Widget> build(BuildContext context) async {
    return poems.isEmpty
        ? Center(child: Text('No poems found.'))
        : ListView.builder(
      itemCount: poems.length,
      itemBuilder: (context, index) {
        final poem = poems[index];
        return ListTile(
          title: Text(poem['title']),
          subtitle: Text('By ${poem['poet_name']} - ${poem['genre_name'] ?? "Unknown Genre"}'),
        );
      },
    );
  }
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _poems = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPoems();
  }

  Future<void> _fetchPoems() async {
    try {
      final poems = await _dbHelper.getPoemsWithDetails();
      setState(() {
        _poems = poems;
        _isLoading = false;
        _errorMessage = _poems.isEmpty ? 'No poems available.' : '';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load poems. Please try again.';
      });
      print('Error fetching poems: $e'); // Debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchPoems,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
            ? Center(child: Text(_errorMessage, style: const TextStyle(fontSize: 16)))
            : ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: _poems.length,
          itemBuilder: (context, index) {
            final poem = _poems[index];
            return PoemCard(
              title: poem['title'],
              content: poem['content'],
              poetName: poem['poet_name'] ?? 'Unknown Poet',
              genre: poem['genre_name'] ?? 'Unknown Genre',
              onLike: () => _handleLike(poem),
              onComment: () => _handleComment(poem),
              onShare: () => _handleShare(poem),
              onBookmark: () => _handleBookmark(poem),
            );
          },
        ),
      ),
    );
  }

  void _handleLike(Map<String, dynamic> poem) {
    print('Liked: ${poem['title']}');
  }

  void _handleComment(Map<String, dynamic> poem) {
    print('Comment on: ${poem['title']}');
  }

  void _handleShare(Map<String, dynamic> poem) {
    print('Shared: ${poem['title']}');
  }

  void _handleBookmark(Map<String, dynamic> poem) {
    print('Bookmarked: ${poem['title']}');
  }
}

class PoemCard extends StatelessWidget {
  final String title;
  final String content;
  final String poetName;
  final String genre;
  final Function onLike;
  final Function onComment;
  final Function onShare;
  final Function onBookmark;

  PoemCard({
    required this.title,
    required this.content,
    required this.poetName,
    required this.genre,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poem Header
            ListTile(
              title: Text(poetName, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Genre: $genre'), // Added genre
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
            // Poem Content
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(height: 10),
            // Interaction Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.favorite_border),
                      onPressed: () => onLike(),
                    ),
                    IconButton(
                      icon: Icon(Icons.comment),
                      onPressed: () => onComment(),
                    ),
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () => onShare(),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.bookmark_border),
                  onPressed: () => onBookmark(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CreatePoemPage extends StatefulWidget {
  final int userId; // Pass the logged-in user's ID to associate the poem with the user.

  CreatePoemPage({required this.userId});

  @override
  _CreatePoemPageState createState() => _CreatePoemPageState();
}

class _CreatePoemPageState extends State<CreatePoemPage> {
  final TextEditingController _poemTitleController = TextEditingController();
  final TextEditingController _poemContentController = TextEditingController();
  final TextEditingController _genreController = TextEditingController(); // For genre input.
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _genreId = 1; // Default genre ID (example: 1).

  @override
  void dispose() {
    _poemTitleController.dispose();
    _poemContentController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  // Method to save the poem to the database
  Future<void> _savePoem() async {
    String title = _poemTitleController.text.trim();
    String content = _poemContentController.text.trim();
    String genre = _genreController.text.trim();

    if (title.isEmpty || content.isEmpty || genre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Insert poem into the database with the new schema
      await _dbHelper.database.then((db) {
        db.insert(
          'poems',
          {
            'title': title,
            'content': content,
            'user_id': widget.userId, // Associate poem with logged-in user
            'genre_id': _genreId, // Assume genre is selected by the user
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'is_published': 1, // Default to published
          },
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Poem saved successfully!')),
      );

      // Clear the input fields
      _poemTitleController.clear();
      _poemContentController.clear();
      _genreController.clear();

      // Optionally, navigate back to the previous page or reset the form
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving poem: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Poem'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Poem Title',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: _poemTitleController,
                decoration: InputDecoration(
                  hintText: 'Enter your poem title...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Poem Content',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: _poemContentController,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: 'Write your poem here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Poem Genre',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: _genreController,
                decoration: InputDecoration(
                  hintText: 'Enter genre (e.g., Love, Nature, etc.)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _savePoem();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExplorePage(poems: [],)),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Poem'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
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
  List<Map<String, dynamic>> _userPoems = [];
  bool _isEditing = false;
  TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // ✅ Fetch user data and then fetch poems (ensures _userData is available first)
  Future<void> _fetchUserData() async {
    try {
      final db = await _dbHelper.database;
      final user = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [widget.username],
        limit: 1,
      );

      if (user.isNotEmpty) {
        setState(() {
          _userData = user.first;
          _bioController.text = _userData?['bio'] ?? '';
        });

        // ✅ Fetch user poems only after _userData is available
        _fetchUserPoems();
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // ✅ Fetch poems safely after user data is loaded
  Future<void> _fetchUserPoems() async {
    if (_userData == null) return; // Ensure _userData is available

    try {
      final db = await _dbHelper.database;
      final poems = await db.query(
        'poems',
        where: 'user_id = ?',
        whereArgs: [_userData?['id']],
        orderBy: 'created_at DESC',
      );

      setState(() {
        _userPoems = poems;
      });
    } catch (e) {
      print('Error fetching user poems: $e');
    }
  }

  // ✅ Fix Bio Update Issue (Ensure Database is Writable)
  Future<void> _updateBio() async {
    if (_userData == null || _bioController.text.isEmpty) return;

    try {
      final db = await _dbHelper.database;
      final rowsAffected = await db.update(
        'users',
        {'bio': _bioController.text},
        where: 'id = ?',
        whereArgs: [_userData?['id']],
      );

      if (rowsAffected > 0) {
        setState(() {
          _userData?['bio'] = _bioController.text;
          _isEditing = false;
        });
        print('Bio updated successfully.');
      } else {
        print('Bio update failed: No rows affected.');
      }
    } catch (e) {
      print('Error updating bio: $e');
    }
  }

  // ✅ Handle logout
  void _logout() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  // ✅ Toggle edit mode
  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _userData == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  _userData?['username'] ?? 'N/A',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  _userData?['email'] ?? 'N/A',
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 10),
                if (_isEditing)
                  TextField(
                    controller: _bioController,
                    decoration: InputDecoration(labelText: 'Edit Bio'),
                    maxLines: null,
                  )
                else if (_userData?['bio'] != null)
                  Text(
                    _userData!['bio'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 10),
                if (_isEditing)
                  ElevatedButton(
                    onPressed: _updateBio,
                    child: const Text('Save Bio'),
                  )
                else
                  ElevatedButton(
                    onPressed: _toggleEdit,
                    child: const Text('Edit Bio'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _userPoems.isEmpty
                ? const Center(child: Text('No poems posted yet.'))
                : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _userPoems.length,
              itemBuilder: (context, index) {
                final poem = _userPoems[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PoemDetailsPage(
                          title: poem['title'],
                          content: poem['content'],
                          poetName: poem['poet_name'] ?? 'Unknown',
                          genre: poem['genre_name'] ?? 'No Genre',
                          isPublished: poem['is_published'] == 1,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          poem['title'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            poem['content'],
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}