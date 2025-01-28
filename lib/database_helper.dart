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
          profile_picture TEXT,
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
          user_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          genre_id INTEGER NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          is_published BOOLEAN DEFAULT 1,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (genre_id) REFERENCES genre (id) ON DELETE SET NULL
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

  Future<Map<String, dynamic>> loginUser(String username,
      String password) async {
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
        bool verify = verifyPassword(
            password, result.first['password'] as String);
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

  Future<int> registerUser(String username, String email,
      String password) async {
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
  Future<int> insertPoem(String title, String content, int userId, int genreId) async {
    if (userId == null || genreId == null) {
      throw Exception('User ID or Genre ID cannot be null');
    }

    final db = await database;
    return db.insert(
      'poems',
      {
        'title': title,
        'content': content,
        'user_id': userId,  // Make sure this is a valid integer
        'genre_id': genreId,  // Make sure this is a valid integer
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_published': 1,  // Default to published
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// Retrieve all poems from the database
  Future<List<Map<String, dynamic>>> getPoems() async {
    final db = await database;
    return db.query('poems', orderBy: 'created_at DESC');
  }

// Retrieve poems along with the user and genre details (join)
  Future<List<Map<String, dynamic>>> getPoemsWithDetails() async {
    final db = await database;
    return db.rawQuery('''
    SELECT poems.*, users.username, genre.name AS genre_name
    FROM poems
    JOIN users ON poems.user_id = users.id
    JOIN genre ON poems.genre_id = genre.id
    ORDER BY poems.created_at DESC
  ''');
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
}
// Modify the getPoems() method to join the necessary tables
Future<List<Map<String, dynamic>>> getPoemsWithDetails() async {
  final db = await DatabaseHelper().database;

  // Query to fetch poems with the poet's name and genre
  final result = await db.rawQuery('''
    SELECT 
      poems.title, 
      poems.content, 
      poems.is_published, 
      users.username AS poet_name, 
      genre.name AS genre_name, 
      users.profile_picture
    FROM poems
    JOIN users ON poems.user_id = users.id
    JOIN genre ON poems.genre_id = genre.id
    ORDER BY poems.created_at DESC
  ''');

  return result;
}