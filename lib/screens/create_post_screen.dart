import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/post_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final PostService _postService = PostService();
  
  String _selectedContentType = 'text';
  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isUploading = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() {
        _selectedContentType = 'image';
        _selectedFilePath = image.path;
        _selectedFileName = image.name;
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _imagePicker.pickVideo(
      source: ImageSource.gallery,
    );
    if (video != null) {
      setState(() {
        _selectedContentType = 'video';
        _selectedFilePath = video.path;
        _selectedFileName = video.name;
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedContentType = 'file';
        _selectedFilePath = result.files.single.path;
        _selectedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _createPost() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      setState(() {
        _isUploading = true;
      });

      try {
        // For now, we'll create text posts without media upload
        // Media upload requires Firebase Storage implementation
        await _postService.createPost(
          adminId: currentUser.id,
          adminName: currentUser.name,
          contentType: _selectedContentType,
          content: _contentController.text.trim(),
          // TODO: Implement media upload
          // mediaUrl: _selectedFilePath != null ? await _uploadMedia() : null,
          // fileName: _selectedFileName,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post created successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create post: $e')),
          );
        }
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Content Type Selection
              const Text(
                'Content Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'text',
                    label: Text('Text'),
                    icon: Icon(Icons.text_fields),
                  ),
                  ButtonSegment(
                    value: 'image',
                    label: Text('Image'),
                    icon: Icon(Icons.image),
                  ),
                  ButtonSegment(
                    value: 'video',
                    label: Text('Video'),
                    icon: Icon(Icons.videocam),
                  ),
                  ButtonSegment(
                    value: 'file',
                    label: Text('File'),
                    icon: Icon(Icons.attach_file),
                  ),
                ],
                selected: {_selectedContentType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedContentType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Media Picker based on content type
              if (_selectedContentType != 'text') ...[
                ElevatedButton.icon(
                  onPressed: () {
                    switch (_selectedContentType) {
                      case 'image':
                        _pickImage();
                        break;
                      case 'video':
                        _pickVideo();
                        break;
                      case 'file':
                        _pickFile();
                        break;
                      default:
                        break;
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: Text('Select ${_selectedContentType.capitalize()}'),
                ),
                if (_selectedFileName != null) ...[
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(_selectedFileName!),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _selectedFilePath = null;
                            _selectedFileName = null;
                          });
                        },
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],

              // Content Text Field
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: _selectedContentType == 'text' 
                      ? 'Post Content' 
                      : 'Description (optional)',
                  border: const OutlineInputBorder(),
                  hintText: _selectedContentType == 'text'
                      ? 'What would you like to share?'
                      : 'Add a description...',
                ),
                validator: (value) {
                  if (_selectedContentType == 'text' && 
                      (value == null || value.trim().isEmpty)) {
                    return 'Please enter content for your post';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isUploading ? null : _createPost,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Create Post',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}