import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bcrypt/bcrypt.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'poetica.db');
    print('Database path: $path'); // Debugging: print database path

    return openDatabase(
      path,
      version: 2, // Incremented version to trigger onUpgrade
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('Running onCreate...');
    try {
      // Create the 'users' table
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL UNIQUE,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          bio TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      print('Users table created.');

      // Create the 'genre' table
      await db.execute('''
        CREATE TABLE genre (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          description TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      print('Genre table created.');

      // Create the 'poems' table
      await db.execute('''
        CREATE TABLE poems (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          genre TEXT NOT NULL,
          author_id INTEGER NOT NULL,
          is_public INTEGER NOT NULL,
          is_draft INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          tags TEXT,
          image_url TEXT,
          FOREIGN KEY(author_id) REFERENCES users(id)
        )
      ''');
      print('Poems table created.');

      // Create the 'likes' table
      await db.execute('''
        CREATE TABLE likes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          poem_id INTEGER NOT NULL,
          user_id INTEGER NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (poem_id) REFERENCES poems (id) ON DELETE CASCADE,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
      print('Likes table created.');

      // Create the 'comments' table
      await db.execute('''
        CREATE TABLE comments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          poem_id INTEGER NOT NULL,
          user_id INTEGER NOT NULL,
          comment_text TEXT NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (poem_id) REFERENCES poems (id) ON DELETE CASCADE,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
      print('Comments table created.');

      // Create the 'notifications' table
      await db.execute('''
        CREATE TABLE notifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          type TEXT NOT NULL,
          reference_id INTEGER,
          message TEXT NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          is_read BOOLEAN DEFAULT 0,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
      print('Notifications table created.');

      // First, let's create the necessary tables
      await db.execute('''
        CREATE TABLE IF NOT EXISTS poems(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          author_id INTEGER NOT NULL,
          genre TEXT,
          is_public INTEGER DEFAULT 1,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (author_id) REFERENCES users (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS saved_poems(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          poem_id INTEGER NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users (id),
          FOREIGN KEY (poem_id) REFERENCES poems (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS poem_likes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          poem_id INTEGER NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users (id),
          FOREIGN KEY (poem_id) REFERENCES poems (id)
        )
      ''');
    } catch (e) {
      print('Error in onCreate: $e');
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion...');
    try {
      if (oldVersion < newVersion) {
        // Drop old tables and recreate them
        await db.execute('DROP TABLE IF EXISTS users');
        await db.execute('DROP TABLE IF EXISTS genre');
        await db.execute('DROP TABLE IF EXISTS poems');
        await db.execute('DROP TABLE IF EXISTS likes');
        await db.execute('DROP TABLE IF EXISTS comments');
        await db.execute('DROP TABLE IF EXISTS notifications');
        await _onCreate(db, newVersion);
      }
    } catch (e) {
      print('Error in onUpgrade: $e');
    }
  }

  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'poetica.db');
    await deleteDatabase(path);
    print('Database deleted successfully.');
  }

  Future<bool> checkTableExists(String tableName) async {
    final db = await database;
    final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?;",
        [tableName]);
    return result.isNotEmpty;
  }

  // Hash the password before saving it to the database
  String hashPassword(String password) {
    // Automatically generates a salt and hashes the password
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  bool verifyPassword(String password, String hashedPassword) {
    // Verifies that the provided password matches the hash
    return BCrypt.checkpw(password, hashedPassword);
  }

  // Check if a user already exists by username
  Future<bool> isUserExists(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  // User-related functions
  Future<int> insertUser(String username, String email, String password) async {
    final db = await database;

    // Hash the password before storing it
    String hashedPassword = hashPassword(password);

    return db.insert(
      'users',
      {
        'username': username.trim(),
        'email': email.trim(),
        'password': hashedPassword
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    final db = await database;

    // Trim the input values to avoid any accidental leading/trailing whitespace
    username = username.trim();
    password = password.trim();

    // Log the input values to ensure they are correct
    print(
        'Attempting to log in with username: $username and password: $password');

    try {
      // Hash the password to compare it with the stored hash in the database
      String hashedPassword = hashPassword(password);

      print(
          'Attempting to log in with username: $username and password: $hashedPassword');
      // Perform the query to check for a matching user
      final result = await db.query(
        'users',
        where: 'username = ? ',
        whereArgs: [username],
        limit: 1,
      );

      // Debugging: print the raw query result
      print('Login query result: $result');

      if (result.isNotEmpty) {
        bool verify =
            verifyPassword(password, result.first['password'] as String);
        print(verify);
        if (!verify) {
          print('Login successful! User found: ${result.first}');
          return result.first; // Return the first matching result
        } else {
          print('No user found with the provided credentials');
          throw Exception("No user found with provided credentials");
        }
      } else {
        print('No user found with the provided credentials');
        throw Exception("No user found with provided credentials");
      }
    } catch (e) {
      print('Error during login: $e');
      throw Exception("Error during login: $e");
    }
  }

  Future<int> registerUser(
      String username, String email, String password) async {
    try {
      final tableExists = await checkTableExists('users');
      if (!tableExists) {
        print('Users table does not exist. Recreating...');
        final db = await database;
        await db.execute('''
          CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL UNIQUE,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          profile_picture TEXT,
          bio TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        ''');
      }

      final exists = await isUserExists(username);
      if (exists) {
        print('User already exists');
        throw Exception('User already exists');
      }

      final id = await insertUser(username, email, password);
      print('User registered with ID: $id'); // Debugging: print user ID
      return id;
    } catch (e) {
      print('Error during registration: $e');
      throw e;
    }
  }

  // Poem-related functions
  Future<void> insertPoem(Map<String, dynamic> poem) async {
    final db = await database;
    await db.insert(
      'poems',
      poem,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> debugPoems() async {
    final db = await database;
    final result = await db.rawQuery('SELECT * FROM poems');
    print("All poems in DB: $result");
  }

// Retrieve all poems from the database
  Future<List<Map<String, dynamic>>> getPoems() async {
    final db = await database;
    return db.query('poems', orderBy: 'created_at DESC');
  }

// Modify the getPoems() method to join the necessary tables
  Future<List<Map<String, dynamic>>> getPoemsWithDetails() async {
    final db = await database; // No need to call DatabaseHelper() again

    // Query to fetch published poems with the poet's name and genre
    final result = await db.rawQuery('''
    SELECT poems.id, poems.title, poems.content, poems.is_published, 
           users.username AS poet_name, genre.name AS genre_name 
    FROM poems
    JOIN users ON poems.user_id = users.id
    LEFT JOIN genre ON poems.genre_id = genre.id  -- Fix table name
    WHERE poems.is_published = 1  -- Show only published poems
    ORDER BY poems.created_at DESC
  ''');

    print("Fetched poems from DB: $result"); // Debugging output

    return result;
  }

// Delete a poem by its ID
  Future<int> deletePoem(int id) async {
    final db = await database;
    return db.delete('poems', where: 'id = ?', whereArgs: [id]);
  }

// Utility to fetch all users (for debugging purposes)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return db.query('users');
  }

// Notifications method (you may want to implement it later)
  getNotifications() {
    // Placeholder for notifications functionality
    print('Notifications method is yet to be implemented.');
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getUserPoems(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        p.*,
        u.username as author_name,
        (SELECT COUNT(*) FROM saved_poems WHERE poem_id = p.id) as is_saved,
        (SELECT COUNT(*) FROM poem_likes WHERE poem_id = p.id) as likes_count
      FROM poems p
      INNER JOIN users u ON p.author_id = u.id
      WHERE p.author_id = ?
      ORDER BY p.created_at DESC
    ''', [userId]);
  }

  Future<Map<String, dynamic>> getUserStats(int? userId) async {
    if (userId == null) {
      return {'followers': 0, 'following': 0};
    }

    final db = await database;
    final followers = await db.rawQuery('''
      SELECT COUNT(*) as count FROM followers 
      WHERE followed_id = ?
    ''', [userId]);

    final following = await db.rawQuery('''
      SELECT COUNT(*) as count FROM followers 
      WHERE follower_id = ?
    ''', [userId]);

    return {
      'followers': Sqflite.firstIntValue(followers) ?? 0,
      'following': Sqflite.firstIntValue(following) ?? 0,
    };
  }

  Future<void> updateUserProfile(int userId, Map<String, dynamic> data) async {
    final db = await database;
    await db.update(
      'users',
      data,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getSavedPoems(int userId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT 
        poems.*,
        users.username as author_name,
        1 as is_saved,
        (SELECT COUNT(*) FROM poem_likes WHERE poem_id = poems.id) as likes_count
      FROM poems
      INNER JOIN saved_poems ON poems.id = saved_poems.poem_id
      INNER JOIN users ON poems.author_id = users.id
      WHERE saved_poems.user_id = ?
      ORDER BY saved_poems.created_at DESC
    ''', [userId]);
  }

  Future<List<Map<String, dynamic>>> getTaggedPoems(int userId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT poems.* FROM poems
      INNER JOIN poem_tags ON poems.id = poem_tags.poem_id
      WHERE poem_tags.user_id = ?
    ''', [userId]);
  }

  Future<void> toggleFollow(int followerId, int followedId) async {
    final db = await database;
    final exists = await db.query(
      'followers',
      where: 'follower_id = ? AND followed_id = ?',
      whereArgs: [followerId, followedId],
    );

    if (exists.isEmpty) {
      await db.insert('followers', {
        'follower_id': followerId,
        'followed_id': followedId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      await db.delete(
        'followers',
        where: 'follower_id = ? AND followed_id = ?',
        whereArgs: [followerId, followedId],
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAllPoems() async {
    final db = await database;
    return db.rawQuery('''
      SELECT poems.*, users.username as author_name, users.profile_picture as author_image
      FROM poems
      INNER JOIN users ON poems.author_id = users.id
      WHERE poems.is_draft = 0
      ORDER BY poems.created_at DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getFollowingPoems(int userId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT poems.*, users.username as author_name, users.profile_picture as author_image
      FROM poems
      INNER JOIN users ON poems.author_id = users.id
      INNER JOIN followers ON poems.author_id = followers.followed_id
      WHERE followers.follower_id = ? AND poems.is_draft = 0
      ORDER BY poems.created_at DESC
    ''', [userId]);
  }

  Future<List<Map<String, dynamic>>> getRecentPoems() async {
    final db = await database;
    return db.rawQuery('''
      SELECT poems.*, users.username as author_name, users.profile_picture as author_image
      FROM poems
      INNER JOIN users ON poems.author_id = users.id
      WHERE poems.is_draft = 0
      ORDER BY poems.created_at DESC
      LIMIT 20
    ''');
  }

  Future<List<Map<String, dynamic>>> searchPoemsAndUsers(String query) async {
    final db = await database;

    // Search users
    final users = await db.rawQuery('''
      SELECT 
        users.*, 
        'user' as type,
        (SELECT COUNT(*) FROM poems WHERE poems.author_id = users.id) as poems_count
      FROM users
      WHERE username LIKE ? OR bio LIKE ?
      LIMIT 10
    ''', ['%$query%', '%$query%']);

    // Search poems
    final poems = await db.rawQuery('''
      SELECT 
        poems.*, 
        'poem' as type,
        users.username as author_name
      FROM poems
      INNER JOIN users ON poems.author_id = users.id
      WHERE title LIKE ? OR content LIKE ?
      LIMIT 10
    ''', ['%$query%', '%$query%']);

    // Combine and sort results
    final results = [...users, ...poems];
    results.sort((a, b) {
      if (a['type'] == b['type']) {
        return 0;
      }
      return a['type'] == 'user' ? -1 : 1;
    });

    return results;
  }

  Future<void> toggleSavePoem(int userId, int poemId) async {
    final db = await database;
    final saved = await db.query(
      'saved_poems',
      where: 'user_id = ? AND poem_id = ?',
      whereArgs: [userId, poemId],
    );

    if (saved.isEmpty) {
      await db.insert('saved_poems', {
        'user_id': userId,
        'poem_id': poemId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      await db.delete(
        'saved_poems',
        where: 'user_id = ? AND poem_id = ?',
        whereArgs: [userId, poemId],
      );
    }
  }
}
