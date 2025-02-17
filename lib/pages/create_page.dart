import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../database/database_helper.dart';

class CreatePage extends StatefulWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic>? poemToEdit;

  const CreatePage({
    super.key,
    required this.user,
    this.poemToEdit,
  });

  @override
  CreatePageState createState() => CreatePageState();
}

class CreatePageState extends State<CreatePage> {
  final TextEditingController _titleController = TextEditingController();
  late QuillController _contentController;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contentFocus = FocusNode();

  bool _isPublic = true;
  String _selectedGenre = 'General';
  bool _isLoading = false;
  bool _isDraft = false;
  bool _hasChanges = false;
  String? _coverImage;

  final List<String> _genres = const [
    'General',
    'Love',
    'Nature',
    'Life',
    'Philosophy',
    'Social',
    'Political',
    'Religious',
    'Other'
  ];

  final ScrollController _editorScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _contentController = QuillController.basic();

    if (widget.poemToEdit != null) {
      _titleController.text = widget.poemToEdit!['title'];
      _contentController = QuillController(
        document: Document.fromJson(widget.poemToEdit!['content']),
        selection: const TextSelection.collapsed(offset: 0),
      );
      _isPublic = widget.poemToEdit!['is_public'] == 1;
      _selectedGenre = widget.poemToEdit!['genre'] ?? 'General';
      _coverImage = widget.poemToEdit!['cover_image'];
    }

    _titleController.addListener(_onChangesMade);
    _contentController.addListener(_onChangesMade);
  }

  void _onChangesMade() {
    if (!_hasChanges && mounted) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final result = await _showSaveDialog();
        if (result == true) {
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () async {
              if (!_hasChanges) {
                Navigator.pop(context);
                return;
              }
              final result = await _showSaveDialog();
              if (result == true && context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            widget.poemToEdit != null ? 'Edit Poem' : 'New Poem',
            style: const TextStyle(color: Colors.black),
          ),
          actions: [
            if (_hasChanges) ...[
              IconButton(
                icon: const Icon(Icons.save_outlined, color: Colors.blue),
                onPressed: () {
                  setState(() => _isDraft = true);
                  _savePoem();
                },
                tooltip: 'Save as Draft',
              ),
              TextButton(
                onPressed: _savePoem,
                child: const Text(
                  'Share',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_coverImage != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(_coverImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _titleController,
                            focusNode: _titleFocus,
                            decoration: const InputDecoration(
                              hintText: 'Title',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 300,
                            child: QuillEditor(
                              focusNode: _contentFocus,
                              scrollController: _editorScrollController,
                              configurations: QuillEditorConfigurations(
                                editorKey: GlobalKey(),
                                scrollable: true,
                                expands: false,
                                padding: const EdgeInsets.all(16),
                                autoFocus: false,
                                readOnly: false,
                                placeholder: 'Write your poem...',
                                maxHeight: 300,
                                minHeight: 100,
                                customStyles: DefaultStyles(
                                  placeHolder: DefaultTextBlockStyle(
                                    const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                    const VerticalSpacing(0, 0),
                                    const VerticalSpacing(0, 0),
                                    null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    QuillToolbar(
                      configurations: QuillToolbarConfigurations(
                        toolbarIconAlignment: WrapAlignment.start,
                        multiRowsDisplay: false,
                        toolbarSectionSpacing: 2,
                        showDividers: false,
                        showFontFamily: false,
                        showFontSize: false,
                        showBoldButton: true,
                        showItalicButton: true,
                        showUnderLineButton: true,
                        showStrikeThrough: false,
                        showInlineCode: false,
                        showColorButton: false,
                        showBackgroundColorButton: false,
                        showClearFormat: true,
                        showAlignmentButtons: true,
                        showLeftAlignment: true,
                        showCenterAlignment: true,
                        showRightAlignment: true,
                        showJustifyAlignment: true,
                        showHeaderStyle: false,
                        showListNumbers: false,
                        showListBullets: false,
                        showListCheck: false,
                        showCodeBlock: false,
                        showQuote: false,
                        showIndent: true,
                        showLink: false,
                        showUndo: true,
                        showRedo: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Genre',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: _genres.map((genre) {
                              return ChoiceChip(
                                label: Text(genre),
                                selected: _selectedGenre == genre,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedGenre = genre;
                                      _hasChanges = true;
                                    });
                                  }
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          ListTile(
                            title: const Text('Cover Image'),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_photo_alternate),
                              onPressed: _pickCoverImage,
                            ),
                          ),
                          SwitchListTile(
                            title: const Text('Make Public'),
                            subtitle: const Text(
                              'When turned off, only you can see this poem',
                            ),
                            value: _isPublic,
                            onChanged: (value) {
                              setState(() {
                                _isPublic = value;
                                _hasChanges = true;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _pickCoverImage() async {
    // Implement image picker
  }

  Future<bool?> _showSaveDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Draft?'),
        content: const Text('Would you like to save this poem as a draft?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () {
              _isDraft = true;
              _savePoem();
              Navigator.pop(context, true);
            },
            child: const Text('Save Draft'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Editing'),
          ),
        ],
      ),
    );
  }

  Future<void> _savePoem() async {
    if (_titleController.text.isEmpty ||
        _contentController.document.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    // Implement save functionality
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }
}
