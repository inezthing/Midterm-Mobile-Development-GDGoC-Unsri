import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String _selectedCommunity = 'All';

  final List<String> _communities = [
    'All', 'Hirono', 'Nyota', 'TCG Pokemon', 'Trinket',
    'Mofusand', 'Snoopy', 'Labubu', 'Molly',
  ];

  final Map<String, Color> _typeColors = {
    'WTS': Color(0xFFE91E8C),
    'WTB': Color(0xFF4CAF50),
    'Discussion': Color(0xFF2196F3),
  };

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m yang lalu';
    if (diff.inHours < 24) return '${diff.inHours}j yang lalu';
    return '${diff.inDays}h yang lalu';
  }

  void _showAddPostDialog(BuildContext context) {
    final state = context.read<AppState>();
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String selectedType = 'Discussion';
    String selectedCommunity = 'Hirono';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D1B2E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Buat Postingan',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800)),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Type + community row
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedType,
                            decoration: const InputDecoration(
                              labelText: 'Tipe',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            items: ['WTS', 'WTB', 'Discussion']
                                .map((t) =>
                                    DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (v) =>
                                setModalState(() => selectedType = v!),
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF2D1B2E),
                                fontSize: 13),
                            dropdownColor:
                                isDark ? const Color(0xFF2D1B2E) : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedCommunity,
                            decoration: const InputDecoration(
                              labelText: 'Komunitas',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            items: _communities
                                .where((c) => c != 'All')
                                .map((c) =>
                                    DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (v) =>
                                setModalState(() => selectedCommunity = v!),
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF2D1B2E),
                                fontSize: 13),
                            dropdownColor:
                                isDark ? const Color(0xFF2D1B2E) : Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Judul postingan',
                        hintText: '[WTB] Cari Hirono Macaron...',
                      ),
                      validator: (v) =>
                          v == null || v.trim().length < 5
                              ? 'Minimal 5 karakter'
                              : null,
                    ),

                    const SizedBox(height: 10),
                    TextFormField(
                      controller: contentCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Konten',
                        hintText: 'Tulis detail, budget, lokasi...',
                        alignLabelWithHint: true,
                      ),
                      validator: (v) =>
                          v == null || v.trim().length < 10
                              ? 'Minimal 10 karakter'
                              : null,
                    ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          final post = CommunityPost(
                            id: 'c${DateTime.now().millisecondsSinceEpoch}',
                            userId: 'u1',
                            userName: 'you',
                            userAvatar: '🌷',
                            community: selectedCommunity,
                            type: selectedType,
                            title: titleCtrl.text.trim(),
                            content: contentCtrl.text.trim(),
                            postedAt: DateTime.now(),
                            replies: [],
                            likes: 0,
                          );
                          state.addPost(post);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Postingan berhasil dibuat! 🎉'),
                              backgroundColor: AppTheme.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Posting Sekarang'),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showConversation(BuildContext context, CommunityPost post) {
    final replyCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final replies = List<String>.from(post.replies);
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.7,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D1B2E) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(post.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ),
                      IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close)),
                    ],
                  ),
                ),
                Divider(color: isDark ? Colors.white12 : Colors.grey[200]),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF3D2040)
                              : AppTheme.blush,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(post.content,
                            style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey[800])),
                      ),
                      const SizedBox(height: 12),
                      if (replies.isEmpty)
                        Center(
                          child: Text('Belum ada balasan. Jadilah yang pertama!',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.grey[400])),
                        ),
                      ...replies.map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppTheme.blush,
                                  child: const Text('👤',
                                      style: TextStyle(fontSize: 12)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white10
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(r,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.grey[800])),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: replyCtrl,
                          decoration: InputDecoration(
                            hintText: 'Tambah balasan...',
                            hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                          style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF2D1B2E),
                              fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (replyCtrl.text.trim().isNotEmpty) {
                            setModal(() => replies.add(replyCtrl.text.trim()));
                            replyCtrl.clear();
                          }
                        },
                        child: const Text('Kirim'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredPosts = _selectedCommunity == 'All'
        ? state.posts
        : state.posts
            .where((p) => p.community == _selectedCommunity)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Komunitas 💬'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Community filter
            SizedBox(
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: _communities.length,
                itemBuilder: (context, index) {
                  final comm = _communities[index];
                  final isSelected = comm == _selectedCommunity;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCommunity = comm),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary
                              : (isDark
                                  ? Colors.white24
                                  : Colors.grey[300]!),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        comm,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white60 : Colors.grey[600]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Posts
            Expanded(
              child: filteredPosts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('💬', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text('Belum ada postingan',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.grey[500])),
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: () =>
                                _showAddPostDialog(context),
                            child: const Text('Jadilah yang pertama posting!',
                                style: TextStyle(color: AppTheme.primary)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = filteredPosts[index];
                        final typeColor =
                            _typeColors[post.type] ?? AppTheme.primary;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () =>
                                _showConversation(context, post),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: AppTheme.blush,
                                        child: Text(post.userAvatar,
                                            style: const TextStyle(
                                                fontSize: 14)),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('@${post.userName}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700,
                                                    fontSize: 12,
                                                    color: isDark
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF2D1B2E))),
                                            Text(
                                                '${post.community} • ${_timeAgo(post.postedAt)}',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: isDark
                                                        ? Colors.white38
                                                        : Colors.grey[400])),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3),
                                        decoration: BoxDecoration(
                                          color: typeColor
                                              .withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          post.type,
                                          style: TextStyle(
                                            color: typeColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    post.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF2D1B2E),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    post.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.grey[600],
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Icon(Icons.chat_bubble_outline,
                                          size: 14,
                                          color: isDark
                                              ? Colors.white38
                                              : Colors.grey[400]),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${post.replies.length} balasan',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: isDark
                                                ? Colors.white38
                                                : Colors.grey[400]),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(Icons.favorite_border,
                                          size: 14,
                                          color: isDark
                                              ? Colors.white38
                                              : Colors.grey[400]),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${post.likes}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: isDark
                                                ? Colors.white38
                                                : Colors.grey[400]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPostDialog(context),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}