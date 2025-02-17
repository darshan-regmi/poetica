import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../database/database_helper.dart';
import 'profile_page.dart';
import 'poem_details_page.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late TabController _tabController;
  List<Map<String, dynamic>> _forYouPoems = [];
  List<Map<String, dynamic>> _followingPoems = [];
  bool _isLoadingForYou = true;
  bool _isLoadingFollowing = true;
  bool _hasMoreForYou = true;
  bool _hasMoreFollowing = true;
  int _forYouPage = 1;
  int _followingPage = 1;
  final int _limit = 10;
  final ScrollController _forYouScrollController = ScrollController();
  final ScrollController _followingScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadForYouPoems();
    _loadFollowingPoems();
    _forYouScrollController.addListener(_onForYouScroll);
    _followingScrollController.addListener(_onFollowingScroll);
  }

  Future<void> _loadForYouPoems({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _forYouPage = 1;
        _hasMoreForYou = true;
        _forYouPoems.clear();
      });
    }

    if (!_hasMoreForYou) return;

    setState(() => _isLoadingForYou = true);

    try {
      final poems = await _dbHelper.getForYouPoems(
        widget.user['id'],
        limit: _limit,
        offset: (_forYouPage - 1) * _limit,
      );

      if (mounted) {
        setState(() {
          _forYouPoems.addAll(poems);
          _hasMoreForYou = poems.length == _limit;
          _forYouPage++;
          _isLoadingForYou = false;
        });
      }
    } catch (e) {
      print('Error loading for you poems: $e');
      setState(() => _isLoadingForYou = false);
    }
  }

  Future<void> _loadFollowingPoems({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _followingPage = 1;
        _hasMoreFollowing = true;
        _followingPoems.clear();
      });
    }

    if (!_hasMoreFollowing) return;

    setState(() => _isLoadingFollowing = true);

    try {
      final poems = await _dbHelper.getFollowingPoems(
        widget.user['id'],
        limit: _limit,
        offset: (_followingPage - 1) * _limit,
      );

      if (mounted) {
        setState(() {
          _followingPoems.addAll(poems);
          _hasMoreFollowing = poems.length == _limit;
          _followingPage++;
          _isLoadingFollowing = false;
        });
      }
    } catch (e) {
      print('Error loading following poems: $e');
      setState(() => _isLoadingFollowing = false);
    }
  }

  void _onForYouScroll() {
    if (_forYouScrollController.position.pixels ==
        _forYouScrollController.position.maxScrollExtent) {
      _loadForYouPoems();
    }
  }

  void _onFollowingScroll() {
    if (_followingScrollController.position.pixels ==
        _followingScrollController.position.maxScrollExtent) {
      _loadFollowingPoems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Poetica'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'For You'),
            Tab(text: 'Following'),
          ],
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildForYouTab(),
          _buildFollowingTab(),
        ],
      ),
    );
  }

  Widget _buildForYouTab() {
    if (_isLoadingForYou && _forYouPoems.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => _loadForYouPoems(refresh: true),
      child: _forYouPoems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, size: 64, color: Colors.grey),
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
              controller: _forYouScrollController,
              itemCount: _forYouPoems.length + (_hasMoreForYou ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _forYouPoems.length) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return _buildPoemCard(_forYouPoems[index]);
              },
            ),
    );
  }

  Widget _buildFollowingTab() {
    if (_isLoadingFollowing && _followingPoems.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => _loadFollowingPoems(refresh: true),
      child: _followingPoems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Follow poets to see their poems here',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              controller: _followingScrollController,
              itemCount: _followingPoems.length + (_hasMoreFollowing ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _followingPoems.length) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return _buildPoemCard(_followingPoems[index]);
              },
            ),
    );
  }

  Widget _buildPoemCard(Map<String, dynamic> poem) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      user: {'id': poem['author_id']},
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: poem['author_image'] != null
                    ? NetworkImage(poem['author_image'])
                    : null,
                child: poem['author_image'] == null
                    ? Text(poem['author_name'][0].toUpperCase())
                    : null,
              ),
            ),
            title: Text(poem['author_name']),
            subtitle: Text(
              timeago.format(DateTime.parse(poem['created_at'])),
            ),
          ),
          if (poem['cover_image'] != null)
            Image.network(
              poem['cover_image'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  poem['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  poem['content'],
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: poem['is_liked'] == 1
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: poem['is_liked'] == 1 ? Colors.red : null,
                count: poem['likes_count'],
                onTap: () => _toggleLike(poem),
              ),
              _buildActionButton(
                icon: Icons.comment_outlined,
                count: poem['comments_count'],
                onTap: () => _navigateToPoemDetails(poem),
              ),
              _buildActionButton(
                icon: poem['is_saved'] == 1
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                color: poem['is_saved'] == 1 ? Colors.blue : null,
                onTap: () => _toggleSave(poem),
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

  Widget _buildActionButton({
    required IconData icon,
    Color? color,
    int? count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color),
            if (count != null) ...[
              SizedBox(width: 4),
              Text(count.toString()),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _toggleLike(Map<String, dynamic> poem) async {
    try {
      await _dbHelper.toggleLike(poem['id'], widget.user['id']);
      _refreshPoem(poem);
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  Future<void> _toggleSave(Map<String, dynamic> poem) async {
    try {
      await _dbHelper.toggleSave(poem['id'], widget.user['id']);
      _refreshPoem(poem);
    } catch (e) {
      print('Error toggling save: $e');
    }
  }

  void _navigateToPoemDetails(Map<String, dynamic> poem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PoemDetailsPage(
          poem: poem,
          currentUser: widget.user,
        ),
      ),
    ).then((value) {
      if (value == true) {
        _refreshPoem(poem);
      }
    });
  }

  Future<void> _refreshPoem(Map<String, dynamic> poem) async {
    try {
      final updatedPoem = await _dbHelper.getPoem(poem['id']);
      if (updatedPoem != null && mounted) {
        setState(() {
          final forYouIndex =
              _forYouPoems.indexWhere((p) => p['id'] == poem['id']);
          if (forYouIndex != -1) {
            _forYouPoems[forYouIndex] = updatedPoem;
          }

          final followingIndex =
              _followingPoems.indexWhere((p) => p['id'] == poem['id']);
          if (followingIndex != -1) {
            _followingPoems[followingIndex] = updatedPoem;
          }
        });
      }
    } catch (e) {
      print('Error refreshing poem: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _forYouScrollController.dispose();
    _followingScrollController.dispose();
    super.dispose();
  }
}
