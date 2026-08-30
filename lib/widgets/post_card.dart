import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../services/post_service.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final UserModel? currentUser;
  final bool isAdmin;

  const PostCard({
    super.key,
    required this.post,
    this.currentUser,
    this.isAdmin = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final PostService _postService = PostService();
  bool _isLoading = false;

  Future<void> _addReaction(String emoji) async {
    if (widget.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _postService.addReaction(
        postId: widget.post.id,
        userId: widget.currentUser!.id,
        emoji: emoji,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add reaction: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeReaction(String emoji) async {
    if (widget.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _postService.removeReaction(
        postId: widget.post.id,
        userId: widget.currentUser!.id,
        emoji: emoji,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove reaction: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showReactionPicker() {
    final emojis = ['❤️', '👍', '🙏', '🎉', '😊', '🔥', '💯', '👏'];
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1,
          ),
          itemCount: emojis.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _addReaction(emojis[index]);
              },
              child: Card(
                child: Center(
                  child: Text(
                    emojis[index],
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header
            Row(
              children: [
                CircleAvatar(
                  child: Text(widget.post.adminName[0].toUpperCase()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.adminName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(widget.post.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isAdmin)
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Post'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'delete') {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Post'),
                            content: const Text('Are you sure you want to delete this post?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          try {
                            await _postService.deletePost(widget.post.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Post deleted successfully')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to delete post: $e')),
                              );
                            }
                          }
                        }
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Content Type Badge
            Chip(
              label: Text(
                widget.post.contentType.toUpperCase(),
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: _getContentTypeColor(widget.post.contentType),
            ),
            const SizedBox(height: 8),

            // Post Content
            if (widget.post.content.isNotEmpty)
              Text(
                widget.post.content,
                style: const TextStyle(fontSize: 16),
              ),
            
            // Media Preview (placeholder for now)
            if (widget.post.mediaUrl != null) ...[
              const SizedBox(height: 12),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getContentTypeIcon(widget.post.contentType),
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.post.fileName ?? 'Media file',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),

            // View Count
            Row(
              children: [
                Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${widget.post.viewCount} views',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Reactions Section
            Row(
              children: [
                // Reaction Counts
                if (widget.post.reactions.isNotEmpty) ...[
                  ...widget.post.reactions.entries.take(3).map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(entry.key),
                          const SizedBox(width: 2),
                          Text(
                            entry.value.toString(),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (widget.post.reactions.length > 3)
                    Text(
                      '+${widget.post.getTotalReactions() - widget.post.reactions.entries.take(3).fold(0, (sum, entry) => sum + entry.value)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
                const Spacer(),
                // Add Reaction Button
                if (!_isLoading)
                  InkWell(
                    onTap: _showReactionPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'React',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getContentTypeColor(String type) {
    switch (type) {
      case 'image':
        return Colors.blue.withOpacity(0.1);
      case 'video':
        return Colors.red.withOpacity(0.1);
      case 'audio':
        return Colors.orange.withOpacity(0.1);
      case 'file':
        return Colors.green.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  IconData _getContentTypeIcon(String type) {
    switch (type) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      case 'audio':
        return Icons.audiotrack;
      case 'file':
        return Icons.attach_file;
      default:
        return Icons.text_fields;
    }
  }
}