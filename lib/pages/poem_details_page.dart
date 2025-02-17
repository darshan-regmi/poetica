import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../database/database_helper.dart';
import 'profile_page.dart';

class PoemDetailsPage extends StatefulWidget {
  final Map<String, dynamic> poem;
  final Map<String, dynamic> currentUser;

  const PoemDetailsPage({
    Key? key,
    required this.poem,
    required this.currentUser,
  }) : super(key: key);

  @override
  _PoemDetailsPageState createState() => _PoemDetailsPageState();
}

class _PoemDetailsPageState extends State<PoemDetailsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _commentController = TextEditingController();
  late QuillController _contentController;
  bool _isLiked = false;
  bool _isSaved = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _comments = [];
  Map<String, dynamic>? _author;

  @override
  void initState() {
    super.initState();
    _contentController = QuillController(
      document: Document.fromJson(widget.poem['content']),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _loadPoemDetails();
  }

  Future<void> _loadPoemDetails() async {
    setState(() => _isLoading = true);
    try {
      final author = await _dbHelper.getUser(widget.poem['author_id']);
      final comments = await _dbHelper.getPoemComments(widget.poem['id']);
      final isLiked = await _dbHelper.isLikedByUser(
        widget.poem['id'],
        widget.currentUser['id'],
      );
      final isSaved = await _dbHelper.isSavedByUser(
        widget.poem['id'],
        widget.currentUser['id'],
      );

      if (mounted) {
        setState(() {
          _author = author;
          _comments = comments;
          _isLiked = isLiked;
          _isSaved = isSaved;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading poem details: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: widget.poem['cover_image'] != null ? 200 : 0,
                  floating: true,
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    if (widget.poem['author_id'] == widget.currentUser['id'])
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.black),
                        onPressed: _editPoem,
                      ),
                    IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.black),
                      onPressed: _showOptions,
                    ),
                  ],
                  flexibleSpace: widget.poem['cover_image'] != null
                      ? FlexibleSpaceBar(
                          background: Image.network(
                            widget.poem['cover_image']!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : null,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _navigateToProfile(_author!),
                              child: CircleAvatar(
                                backgroundImage: _author!['profile_picture'] !=
                                        null
                                    ? NetworkImage(_author!['profile_picture'])
                                    : null,
                                child: _author!['profile_picture'] == null
                                    ? Text(
                                        _author!['username'][0].toUpperCase())
                                    : null,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () => _navigateToProfile(_author!),
                                    child: Text(
                                      _author!['username'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    timeago.format(
                                      DateTime.parse(widget.poem['created_at']),
                                    ),
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            if (widget.currentUser['id'] != _author!['id'])
                              TextButton(
                                onPressed: _toggleFollow,
                                child: Text(
                                  _author!['is_following'] == 1
                                      ? 'Following'
                                      : 'Follow',
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          widget.poem['title'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: null,
                          child: QuillEditor(
                            controller: _contentController,
                            scrollController: ScrollController(),
                            scrollable: true,
                            focusNode: FocusNode(),
                            autoFocus: false,
                            readOnly: true,
                            expands: false,
                            padding: EdgeInsets.zero,
                            showCursor: false,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isLiked ? Colors.red : null,
                              ),
                              onPressed: _toggleLike,
                            ),
                            IconButton(
                              icon: Icon(Icons.comment_outlined),
                              onPressed: _focusComment,
                            ),
                            IconButton(
                              icon: Icon(
                                _isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                              ),
                              onPressed: _toggleSave,
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.share_outlined),
                              onPressed: _sharePoem,
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.poem['likes_count']} likes',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Genre: ${widget.poem['genre']}',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        if (_comments.isNotEmpty) ...[
                          SizedBox(height: 16),
                          Text(
                            'Comments',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              return _buildCommentTile(_comments[index]);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: widget.currentUser['profile_picture'] != null
                    ? NetworkImage(widget.currentUser['profile_picture'])
                    : null,
                child: widget.currentUser['profile_picture'] == null
                    ? Text(widget.currentUser['username'][0].toUpperCase())
                    : null,
                radius: 16,
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: _addComment,
                ),
              ),
              TextButton(
                onPressed: () => _addComment(_commentController.text),
                child: Text('Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... Helper methods implementation ...
  void _navigateToProfile(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(user: user),
      ),
    );
  }

  Future<void> _toggleLike() async {
    try {
      await _dbHelper.toggleLike(
        widget.currentUser['id'],
        widget.poem['id'],
      );
      _loadPoemDetails();
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
      _loadPoemDetails();
    } catch (e) {
      print('Error toggling save: $e');
    }
  }

  Future<void> _toggleFollow() async {
    try {
      await _dbHelper.toggleFollow(
        widget.currentUser['id'],
        _author!['id'],
      );
      _loadPoemDetails();
    } catch (e) {
      print('Error toggling follow: $e');
    }
  }

  void _focusComment() {
    FocusScope.of(context).requestFocus(
      _commentController.buildTextSpan().toPlainText().isEmpty
          ? FocusNode()
          : null,
    );
  }

  Future<void> _addComment(String text) async {
    if (text.isEmpty) return;

    try {
      await _dbHelper.addComment(
        widget.poem['id'],
        widget.currentUser['id'],
        text,
      );
      _commentController.clear();
      _loadPoemDetails();
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  void _editPoem() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePage(
          user: widget.currentUser,
          poemToEdit: widget.poem,
        ),
      ),
    );
  }

  Future<void> _sharePoem() async {
    try {
      await Share.share(
        '${widget.poem['title']} by ${_author!['username']}\n\n'
        '${_contentController.document.toPlainText()}\n\n'
        'Read more on Poetica',
      );
    } catch (e) {
      print('Error sharing poem: $e');
    }
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.poem['author_id'] == widget.currentUser['id']) ...[
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _editPoem();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deletePoem();
              },
            ),
          ] else ...[
            ListTile(
              leading: Icon(Icons.person_add_outlined),
              title: Text(
                _author!['is_following'] == 1
                    ? 'Unfollow ${_author!['username']}'
                    : 'Follow ${_author!['username']}',
              ),
              onTap: () {
                Navigator.pop(context);
                _toggleFollow();
              },
            ),
          ],
          ListTile(
            leading: Icon(Icons.share),
            title: Text('Share'),
            onTap: () {
              Navigator.pop(context);
              _sharePoem();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deletePoem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Poem'),
        content: Text('Are you sure you want to delete this poem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _dbHelper.deletePoem(widget.poem['id']);
        Navigator.pop(context, true);
      } catch (e) {
        print('Error deleting poem: $e');
      }
    }
  }

  Widget _buildCommentTile(Map<String, dynamic> comment) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _navigateToProfile(comment),
            child: CircleAvatar(
              backgroundImage: comment['user_image'] != null
                  ? NetworkImage(comment['user_image'])
                  : null,
              child: comment['user_image'] == null
                  ? Text(comment['username'][0].toUpperCase())
                  : null,
              radius: 16,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: comment['username'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' '),
                      TextSpan(text: comment['content']),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  timeago.format(DateTime.parse(comment['created_at'])),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
