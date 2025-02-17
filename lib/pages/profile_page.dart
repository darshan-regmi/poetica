import 'package:flutter/material.dart';
import '../database_helper.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;
  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _poems = [];
  List<Map<String, dynamic>> _savedPoems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final poems = await _dbHelper.getUserPoems(widget.user['id']);
      final savedPoems = await _dbHelper.getSavedPoems(widget.user['id']);
      if (mounted) {
        setState(() {
          _poems = poems;
          _savedPoems = savedPoems;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
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
          widget.user['username'],
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              // Show menu options
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(height: 16),
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: widget.user['profile_picture'] != null
                            ? NetworkImage(widget.user['profile_picture'])
                            : null,
                        child: widget.user['profile_picture'] == null
                            ? Text(
                                widget.user['username'][0].toUpperCase(),
                                style: TextStyle(fontSize: 32),
                              )
                            : null,
                      ),
                      SizedBox(height: 16),
                      Text(
                        widget.user['username'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.user['bio'] != null) ...[
                        SizedBox(height: 8),
                        Text(widget.user['bio']),
                      ],
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn('Poems', _poems.length.toString()),
                          _buildStatColumn(
                            'Followers',
                            widget.user['followers_count'].toString(),
                          ),
                          _buildStatColumn(
                            'Following',
                            widget.user['following_count'].toString(),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      if (widget.user['id'] == widget.user['id'])
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to edit profile
                          },
                          child: Text('Edit Profile'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: _toggleFollow,
                          child: Text(
                            widget.user['is_following'] == 1
                                ? 'Following'
                                : 'Follow',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.user['is_following'] == 1
                                ? Colors.white
                                : Colors.blue,
                            foregroundColor: widget.user['is_following'] == 1
                                ? Colors.black
                                : Colors.white,
                            side: BorderSide(
                              color: widget.user['is_following'] == 1
                                  ? Colors.grey[300]!
                                  : Colors.blue,
                            ),
                          ),
                        ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
              body: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(icon: Icon(Icons.grid_on)),
                      Tab(icon: Icon(Icons.bookmark_border)),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPoemsGrid(_poems),
                        _buildPoemsGrid(_savedPoems),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPoemsGrid(List<Map<String, dynamic>> poems) {
    return GridView.builder(
      padding: EdgeInsets.all(4),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: poems.length,
      itemBuilder: (context, index) {
        final poem = poems[index];
        return GestureDetector(
          onTap: () {
            // Navigate to poem details
          },
          child: Container(
            color: Colors.grey[200],
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  poem['title'],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleFollow() async {
    try {
      await _dbHelper.toggleFollow(widget.user['id'], widget.user['id']);
      _loadUserData();
    } catch (e) {
      print('Error toggling follow: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
