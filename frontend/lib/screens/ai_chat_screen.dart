import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/ai_jobs_service.dart';
import '../api/r2v_api.dart';
import '../api/api_exception.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final FocusNode _keyboardFocus = FocusNode();
  bool _enterHandled = false;

  PlatformFile? uploadedImage;
  bool _isTyping = false;

  int _activeIndex = 1; 
  int? _hoverIndex;

  final TextEditingController _chatSearchController = TextEditingController();
  String _chatSearch = "";

  final List<_Conversation> _conversations = [
    _Conversation(id: "c1", title: "New chat"),
  ];
  String _activeConversationId = "c1";

  _Conversation get _activeConversation =>
      _conversations.firstWhere((c) => c.id == _activeConversationId);

  List<_Conversation> get _filteredConversations {
    final q = _chatSearch.trim().toLowerCase();
    if (q.isEmpty) return _conversations;
    return _conversations.where((c) => c.title.toLowerCase().contains(q)).toList();
  }

  void _newChat() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _conversations.insert(0, _Conversation(id: id, title: "New chat"));
      _activeConversationId = id;
      _isTyping = false;
      uploadedImage = null;
      _controller.clear();
    });
    _scrollToBottom();
  }

  void _selectChat(String id) {
    setState(() {
      _activeConversationId = id;
      _isTyping = false;
      uploadedImage = null;
      _controller.clear();
    });
    _scrollToBottom();
  }

  void _deleteChat(String id) {
    if (_conversations.length <= 1) {
      setState(() {
        _conversations[0]
          ..title = "New chat"
          ..messages.clear();
        _activeConversationId = _conversations[0].id;
        _isTyping = false;
        uploadedImage = null;
        _controller.clear();
      });
      _scrollToBottom();
      return;
    }

    setState(() {
      final wasActive = id == _activeConversationId;
      _conversations.removeWhere((c) => c.id == id);

      if (wasActive) {
        _activeConversationId = _conversations.first.id;
        _isTyping = false;
        uploadedImage = null;
        _controller.clear();
      }
    });
    _scrollToBottom();
  }

  Future<void> _renameChat(String id, bool isDark) async {
    final conv = _conversations.firstWhere((c) => c.id == id);
    final tc = TextEditingController(text: conv.title == "New chat" ? "" : conv.title);

    final newTitle = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0B0D14) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Rename chat", style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B))),
          content: TextField(
            controller: tc,
            autofocus: true,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: "Enter a title",
              hintStyle: TextStyle(color: isDark ? Colors.white.withOpacity(0.5) : Colors.black38),
              filled: true,
              fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.12) : Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFBC70FF)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel", style: TextStyle(color: isDark ? Colors.white.withOpacity(0.8) : Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () {
                final v = tc.text.trim();
                Navigator.pop(ctx, v.isEmpty ? null : v);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A4FFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: isDark ? 0 : 4,
              ),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (newTitle == null) return;

    setState(() {
      conv.title = newTitle;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 220,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty && uploadedImage == null) return;

    final image = uploadedImage;
    setState(() {
      _activeConversation.messages.add(
        _ChatMessage(text.isEmpty ? "[Image Uploaded]" : text, uploadedImage, true),
      );

      final conv = _activeConversation;
      if (conv.title == "New chat" && text.isNotEmpty) {
        conv.title = text.length > 28 ? "${text.substring(0, 28)}…" : text;
      }

      _controller.clear();
      uploadedImage = null;
      _isTyping = true;
    });

    _scrollToBottom();

    final prompt = text.isEmpty ? "Image upload" : text;
    final settings = <String, dynamic>{};
    final bytes = image?.bytes;
    if (bytes != null && bytes.isNotEmpty) {
      settings['image_filename'] = image?.name ?? 'upload.png';
      settings['image_base64'] = base64Encode(bytes);
    }

    try {
      final job = await r2vAiJobs.createJob(prompt: prompt, settings: settings);
      final assistantMessage = _ChatMessage(_formatJobStatus(job), null, false);
      setState(() => _activeConversation.messages.add(assistantMessage));
      _scrollToBottom();
      await _pollJobStatus(job.id, assistantMessage, initialJob: job);
    } on ApiException catch (e) {
      await _animateTyping("Failed to create job: ${e.message}");
    } catch (_) {
      await _animateTyping("Failed to create job. Please try again.");
    }
  }

  Future<void> _pollJobStatus(
    String jobId,
    _ChatMessage message, {
    AiJob? initialJob,
  }) async {
    var currentJob = initialJob;
    var attempts = 0;
    const maxAttempts = 150;
    const delay = Duration(seconds: 2);

    while (mounted &&
        attempts < maxAttempts &&
        currentJob != null &&
        !_isJobComplete(currentJob)) {
      await Future.delayed(delay);
      if (!mounted) return;

      try {
        currentJob = await r2vAiJobs.getJob(jobId);
      } catch (_) {
        attempts++;
        continue;
      }

      if (!mounted || currentJob == null) return;

      setState(() {
        message.text = _formatJobStatus(
          currentJob!,
          hasDownload: message.modelUrl?.isNotEmpty == true,
        );
      });
      _scrollToBottom();
      attempts++;
    }

    if (!mounted) return;

    if (currentJob != null && _isJobComplete(currentJob)) {
      setState(() {
        message.text = _formatJobStatus(
          currentJob!,
          hasDownload: message.modelUrl?.isNotEmpty == true,
        );
        _isTyping = false;
      });
      _scrollToBottom();
      if (currentJob.status == "succeeded") {
        await _attachModelDownload(jobId, message, currentJob);
      }
      return;
    }

    setState(() {
      final fallback = currentJob ?? initialJob;
      message.text = [
        if (fallback != null)
          _formatJobStatus(
            fallback,
            hasDownload: message.modelUrl?.isNotEmpty == true,
          ),
        "Still processing. You can check back later in your dashboard.",
      ].join("\n");
      _isTyping = false;
    });
    _scrollToBottom();
  }

  bool _isJobComplete(AiJob job) {
    return job.status == "succeeded" || job.status == "failed";
  }

  String _formatJobStatus(
    AiJob job, {
    bool hasDownload = false,
    String? downloadError,
  }) {
    final buffer = StringBuffer()
      ..writeln("Job ${job.id}")
      ..writeln("Status: ${job.status} (${job.progress}%)");

    if (job.status == "succeeded") {
      if (hasDownload) {
        buffer.writeln("Your model is ready. Preview it below or download it.");
      } else if (downloadError != null && downloadError.isNotEmpty) {
        buffer.writeln("Model ready, but the download link failed: $downloadError");
      } else {
        buffer.writeln("Your model is ready. Fetching the preview...");
      }
    }

    if (job.status == "failed" && job.error != null && job.error!.isNotEmpty) {
      buffer.writeln("Error: ${job.error}");
    }

    return buffer.toString().trimRight();
  }

  Future<void> _attachModelDownload(String jobId, _ChatMessage message, AiJob job) async {
    if (message.modelUrl?.isNotEmpty == true) {
      return;
    }
    try {
      final url = await r2vAiJobs.downloadGlb(jobId);
      if (!mounted) return;
      if (url.isEmpty) {
        setState(() {
          message.text = _formatJobStatus(
            job,
            hasDownload: false,
            downloadError: "Missing download URL",
          );
        });
        return;
      }
      setState(() {
        message.modelUrl = url;
        message.text = _formatJobStatus(job, hasDownload: true);
      });
      _scrollToBottom();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        message.text = _formatJobStatus(
          job,
          hasDownload: false,
          downloadError: e.message,
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        message.text = _formatJobStatus(
          job,
          hasDownload: false,
          downloadError: "Unable to fetch download link",
        );
      });
    }
  }

  Future<void> _animateTyping(String text) async {
    String current = "";
    setState(() => _activeConversation.messages.add(_ChatMessage("", null, false)));

    for (int i = 0; i < text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 7));
      if (!mounted) return;
      setState(() {
        current += text[i];
        _activeConversation.messages.last.text = current;
      });
      _scrollToBottom();
    }

    if (mounted) setState(() => _isTyping = false);
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null) {
      setState(() => uploadedImage = result.files.first);
      _sendMessage();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _keyboardFocus.dispose();
    _chatSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(child: MeshyParticleBackground(isDark: isDark)),
        Positioned.fill(
          child: isWide ? _buildWide(context, isDark) : _buildMobile(context, isDark),
        ),
      ],
    );
  }

  Widget _buildWide(BuildContext context, bool isDark) {
    final w = MediaQuery.of(context).size.width;
    final double rightMaxWidth = w > 1500 ? 1500 : w;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: _GlassTopBar(
                activeIndex: _activeIndex,
                hoverIndex: _hoverIndex,
                isDark: isDark,
                onHover: (v) => setState(() => _hoverIndex = v),
                onLeave: () => setState(() => _hoverIndex = null),
                onNavTap: (idx) {
                  setState(() => _activeIndex = idx);
                  switch (idx) {
                    case 0: Navigator.pushNamed(context, '/home'); break;
                    case 1: break; 
                    case 2: Navigator.pushNamed(context, '/explore'); break;
                    case 3: Navigator.pushNamed(context, '/settings'); break;
                  }
                },
                onProfile: () => Navigator.pushNamed(context, '/profile'),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 310,
                      child: _LeftChatSidebar(
                        conversations: _filteredConversations,
                        activeId: _activeConversationId,
                        isDark: isDark,
                        onNewChat: _newChat,
                        onSelect: _selectChat,
                        searchController: _chatSearchController,
                        onSearchChanged: (v) => setState(() => _chatSearch = v),
                        onRename: (id) => _renameChat(id, isDark),
                        onDelete: _deleteChat,
                        onUserMenu: (action) {
                          switch (action) {
                            case _UserMenuAction.profile: Navigator.pushNamed(context, '/profile'); break;
                            case _UserMenuAction.settings: Navigator.pushNamed(context, '/settings'); break;
                            case _UserMenuAction.newChat: _newChat(); break;
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: rightMaxWidth),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.black.withOpacity(0.16) : Colors.white.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(26),
                                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.10) : Colors.white),
                                  boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: _ChatPanel(
                                        messages: _activeConversation.messages,
                                        controller: _scrollController,
                                        isTyping: _isTyping,
                                        isDark: isDark,
                                        padding: const EdgeInsets.fromLTRB(22, 18, 22, 96),
                                      ),
                                    ),
                                    Positioned(
                                      left: 14, right: 14, bottom: 14,
                                      child: _inputBar(isDark),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobile(BuildContext context, bool isDark) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          _activeConversation.title == "New chat" ? "AI Studio" : _activeConversation.title,
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.w700),
        ),
        backgroundColor: isDark ? Colors.black.withOpacity(0.15) : Colors.white.withOpacity(0.7),
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : const Color(0xFF1E293B)),
        actions: [
          IconButton(
            tooltip: "New chat",
            onPressed: _newChat,
            icon: Icon(Icons.add_rounded, color: isDark ? Colors.white : const Color(0xFF1E293B)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _ChatPanel(
              messages: _activeConversation.messages,
              controller: _scrollController,
              isTyping: _isTyping,
              isDark: isDark,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: _inputBar(isDark),
          ),
        ],
      ),
    );
  }

  Widget _inputBar(bool isDark) {
    return RawKeyboardListener(
      focusNode: _keyboardFocus,
      onKey: (event) {
        if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
          if (_enterHandled) return;
          _enterHandled = true;

          if (event.isShiftPressed) {
            final text = _controller.text;
            final newText = "$text\n";
            _controller.text = newText;
            _controller.selection = TextSelection.fromPosition(TextPosition(offset: newText.length));
          } else {
            _sendMessage();
          }
        }

        if (event is RawKeyUpEvent && event.logicalKey == LogicalKeyboardKey.enter) {
          _enterHandled = false;
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withOpacity(0.22) : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.10) : Colors.white),
              boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: const Icon(Icons.image_rounded, color: Color(0xFFBC70FF)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: "Type a prompt or upload an image...",
                      hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black38),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF8A4FFF), Color(0xFFBC70FF)],
                      ),
                    ),
                    child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Conversation {
  final String id;
  String title;
  final List<_ChatMessage> messages;

  _Conversation({required this.id, required this.title, List<_ChatMessage>? messages})
      : messages = messages ?? [];
}

class _ChatMessage {
  String text;
  final PlatformFile? image;
  final bool isUser;
  String? modelUrl;

  _ChatMessage(this.text, this.image, this.isUser, {this.modelUrl});
}

class _GlassTopBar extends StatelessWidget {
  final int activeIndex;
  final int? hoverIndex;
  final void Function(int? idx) onHover;
  final VoidCallback onLeave;
  final void Function(int idx) onNavTap;
  final VoidCallback onProfile;
  final bool isDark;

  const _GlassTopBar({
    required this.activeIndex,
    required this.hoverIndex,
    required this.onHover,
    required this.onLeave,
    required this.onNavTap,
    required this.onProfile,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withOpacity(0.35) : Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.9)),
            boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 26, color: Color(0xFFBC70FF)),
              const SizedBox(width: 8),
              Text(
                "R2V Studio",
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              SizedBox(
                width: 380,
                child: _TopTabs(
                  activeIndex: activeIndex,
                  hoverIndex: hoverIndex,
                  isDark: isDark,
                  onHover: onHover,
                  onLeave: onLeave,
                  onTap: onNavTap,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: onProfile,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.18) : Colors.black.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: isDark ? Colors.white : const Color(0xFF1E293B), size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopTabs extends StatelessWidget {
  final int activeIndex;
  final int? hoverIndex;
  final void Function(int? idx) onHover;
  final VoidCallback onLeave;
  final void Function(int idx) onTap;
  final bool isDark;

  const _TopTabs({
    required this.activeIndex,
    required this.hoverIndex,
    required this.onHover,
    required this.onLeave,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final labels = ["Home", "AI Studio", "Marketplace", "Settings"];
    final navCount = labels.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final segmentWidth = totalWidth / navCount;
        const indicatorWidth = 48.0;

        final underlineIndex = (hoverIndex ?? activeIndex).clamp(0, navCount - 1);
        final underlineLeft = underlineIndex * segmentWidth + (segmentWidth - indicatorWidth) / 2;

        return SizedBox(
          height: 34,
          child: Stack(
            children: [
              Row(
                children: List.generate(navCount, (index) {
                  final isActive = activeIndex == index;
                  final isHover = hoverIndex == index;
                  final effective = isActive || isHover;

                  return MouseRegion(
                    onEnter: (_) => onHover(index),
                    onExit: (_) => onHover(null),
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => onTap(index),
                      child: SizedBox(
                        width: segmentWidth,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 120),
                            style: TextStyle(
                              color: effective ? (isDark ? Colors.white : const Color(0xFF1E293B)) : (isDark ? Colors.white.withOpacity(0.7) : Colors.black54),
                              fontWeight: effective ? FontWeight.w600 : FontWeight.w400,
                              fontSize: 13.5,
                            ),
                            child: Text(labels[index]),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                left: underlineLeft,
                bottom: 0,
                child: Container(
                  width: indicatorWidth,
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBC70FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _ChatMenuAction { rename, delete }
enum _UserMenuAction { profile, settings, newChat }

class _LeftChatSidebar extends StatelessWidget {
  final List<_Conversation> conversations;
  final String activeId;
  final VoidCallback onNewChat;
  final void Function(String id) onSelect;

  final TextEditingController searchController;
  final void Function(String text) onSearchChanged;

  final Future<void> Function(String id) onRename;
  final void Function(String id) onDelete;
  final void Function(_UserMenuAction action) onUserMenu;
  final bool isDark;

  const _LeftChatSidebar({
    required this.conversations,
    required this.activeId,
    required this.onNewChat,
    required this.onSelect,
    required this.searchController,
    required this.onSearchChanged,
    required this.onRename,
    required this.onDelete,
    required this.onUserMenu,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0B0D14).withOpacity(0.55) : Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.10) : Colors.white),
            boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Column(
            children: [
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: onNewChat,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text("New chat"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A4FFF),
                      foregroundColor: Colors.white,
                      elevation: isDark ? 0 : 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: isDark ? Colors.white.withOpacity(0.6) : Colors.black38, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: onSearchChanged,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: "Search chats",
                            hintStyle: TextStyle(color: isDark ? Colors.white.withOpacity(0.55) : Colors.black38, fontSize: 13),
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                        ),
                      ),
                      if (searchController.text.trim().isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            searchController.clear();
                            onSearchChanged("");
                            FocusScope.of(context).unfocus();
                          },
                          child: Icon(Icons.close_rounded, color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54, size: 18),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Divider(color: isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.05), height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  itemCount: conversations.length,
                  itemBuilder: (context, i) {
                    final c = conversations[i];
                    final active = c.id == activeId;

                    return _ChatHistoryTile(
                      title: c.title,
                      active: active,
                      isDark: isDark,
                      onTap: () => onSelect(c.id),
                      onMenu: (action) async {
                        switch (action) {
                          case _ChatMenuAction.rename: await onRename(c.id); break;
                          case _ChatMenuAction.delete: onDelete(c.id); break;
                        }
                      },
                    );
                  },
                ),
              ),
              Divider(color: isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.05), height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? Colors.white.withOpacity(0.10) : Colors.transparent),
                      ),
                      child: Icon(Icons.person, color: isDark ? Colors.white70 : Colors.black54, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "R2V User",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white.withOpacity(0.85) : const Color(0xFF1E293B),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    PopupMenuButton<_UserMenuAction>(
                      tooltip: "More",
                      color: isDark ? const Color(0xFF0B0D14) : Colors.white,
                      icon: Icon(Icons.more_horiz_rounded, color: isDark ? Colors.white.withOpacity(0.75) : Colors.black54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      onSelected: onUserMenu,
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: _UserMenuAction.profile,
                          child: _MenuRow(icon: Icons.person_outline_rounded, label: "Profile", isDark: isDark),
                        ),
                        PopupMenuItem(
                          value: _UserMenuAction.settings,
                          child: _MenuRow(icon: Icons.settings_outlined, label: "Settings", isDark: isDark),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: _UserMenuAction.newChat,
                          child: _MenuRow(icon: Icons.add_rounded, label: "New chat", isDark: isDark),
                        ),
                      ],
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
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _MenuRow({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: isDark ? Colors.white.withOpacity(0.85) : Colors.black87, size: 18),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
      ],
    );
  }
}

class _ChatHistoryTile extends StatelessWidget {
  final String title;
  final bool active;
  final VoidCallback onTap;
  final void Function(_ChatMenuAction action) onMenu;
  final bool isDark;

  const _ChatHistoryTile({
    required this.title,
    required this.active,
    required this.onTap,
    required this.onMenu,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: active ? (isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.04)) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? (isDark ? Colors.white.withOpacity(0.14) : Colors.transparent) : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              color: isDark ? Colors.white.withOpacity(active ? 0.85 : 0.55) : (active ? const Color(0xFF1E293B) : Colors.black54),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? Colors.white.withOpacity(active ? 0.92 : 0.70) : (active ? const Color(0xFF1E293B) : Colors.black87),
                  fontSize: 13.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 6),
            PopupMenuButton<_ChatMenuAction>(
              tooltip: "Chat options",
              color: isDark ? const Color(0xFF0B0D14) : Colors.white,
              icon: Icon(Icons.more_vert_rounded, color: isDark ? Colors.white.withOpacity(0.70) : Colors.black54, size: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              onSelected: onMenu,
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: _ChatMenuAction.rename,
                  child: _MenuRow(icon: Icons.edit_rounded, label: "Rename", isDark: isDark),
                ),
                PopupMenuItem(
                  value: _ChatMenuAction.delete,
                  child: _MenuRow(icon: Icons.delete_outline_rounded, label: "Delete", isDark: isDark),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatPanel extends StatelessWidget {
  final List<_ChatMessage> messages;
  final ScrollController controller;
  final bool isTyping;
  final EdgeInsets? padding;
  final bool isDark;

  const _ChatPanel({
    required this.messages,
    required this.controller,
    required this.isTyping,
    required this.isDark,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding ?? const EdgeInsets.fromLTRB(20, 18, 20, 18),
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (isTyping && index == messages.length) {
          return Align(alignment: Alignment.centerLeft, child: _TypingBubble(isDark: isDark));
        }

        final msg = messages[index];
        return Align(
          alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: _ChatBubble(message: msg, isDark: isDark),
        );
      },
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  final bool isDark;

  const _ChatBubble({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      constraints: const BoxConstraints(maxWidth: 560),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: isUser
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8A4FFF), Color(0xFFBC70FF)],
              )
            : null,
        color: isUser ? null : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04)),
        border: Border.all(color: isUser ? Colors.white.withOpacity(0.14) : (isDark ? Colors.white.withOpacity(0.10) : Colors.transparent)),
        boxShadow: [
          if (isUser)
             BoxShadow(blurRadius: 18, color: const Color(0xFF8A4FFF).withOpacity(isDark ? 0.35 : 0.2), offset: const Offset(0, 10))
          else if (isDark)
             BoxShadow(blurRadius: 18, color: Colors.black.withOpacity(0.25), offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.image != null && (message.image!.bytes?.isNotEmpty ?? false))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.memory(
                  message.image!.bytes!,
                  height: 170,
                  width: 320,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Text(
            message.text,
            style: TextStyle(
              color: isUser ? Colors.white : (isDark ? Colors.white.withOpacity(0.96) : const Color(0xFF1E293B)),
              fontSize: 14.5,
              height: 1.35,
              fontWeight: isUser ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          if (!isUser && message.modelUrl?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Container(
                  color: isDark ? Colors.black.withOpacity(0.18) : Colors.black.withOpacity(0.05),
                  child: ModelViewer(
                    key: ValueKey(message.modelUrl),
                    src: message.modelUrl!,
                    backgroundColor: Colors.transparent,
                    cameraControls: true,
                    autoRotate: true,
                    environmentImage: "neutral",
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () async {
                final url = message.modelUrl;
                if (url == null || url.isEmpty) return;
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text("Download GLB"),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                backgroundColor: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  final bool isDark;
  const _TypingBubble({required this.isDark});

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value;
        final a = (sin(t * pi * 2) * 0.5 + 0.5);
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: widget.isDark ? Colors.white.withOpacity(0.10) : Colors.transparent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dot(opacity: 0.25 + 0.55 * a),
              const SizedBox(width: 6),
              _dot(opacity: 0.25 + 0.55 * (1 - a)),
              const SizedBox(width: 6),
              _dot(opacity: 0.25 + 0.55 * a),
              const SizedBox(width: 10),
              Text("Typing...", style: TextStyle(color: widget.isDark ? Colors.white.withOpacity(0.75) : Colors.black54, fontSize: 13)),
            ],
          ),
        );
      },
    );
  }

  Widget _dot({required double opacity}) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: widget.isDark ? Colors.white.withOpacity(opacity) : Colors.black.withOpacity(opacity), shape: BoxShape.circle),
    );
  }
}

class MeshyParticleBackground extends StatelessWidget {
  final bool isDark;
  const MeshyParticleBackground({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: _MeshyBgCore(isDark: isDark));
  }
}

class _MeshyBgCore extends StatefulWidget {
  final bool isDark;
  const _MeshyBgCore({required this.isDark});

  @override
  State<_MeshyBgCore> createState() => _MeshyBgCoreState();
}

class _MeshyBgCoreState extends State<_MeshyBgCore> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final Random _rng = Random(42);

  Size _size = Size.zero;
  Offset _mouse = Offset.zero;
  bool _hasMouse = false;

  late List<_Particle> _ps;
  double _t = 0;

  @override
  void initState() {
    super.initState();
    _ps = <_Particle>[];
    _ticker = createTicker((elapsed) {
      _t = elapsed.inMilliseconds / 1000.0;
      if (!mounted) return;
      if (_size == Size.zero) return;

      const dt = 1 / 60;
      for (final p in _ps) {
        p.pos = p.pos + p.vel * dt;
        if (p.pos.dx < 0 || p.pos.dx > _size.width) p.vel = Offset(-p.vel.dx, p.vel.dy);
        if (p.pos.dy < 0 || p.pos.dy > _size.height) p.vel = Offset(p.vel.dx, -p.vel.dy);
        p.pos = Offset(p.pos.dx.clamp(0.0, _size.width), p.pos.dy.clamp(0.0, _size.height));
      }
      setState(() {});
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _ensureParticles(Size s) {
    if (s == Size.zero) return;

    final area = s.width * s.height;
    int target = (area / 18000).round();
    target = target.clamp(35, 95);

    if (_ps.length == target) return;

    _ps = List.generate(target, (i) {
      final pos = Offset(_rng.nextDouble() * s.width, _rng.nextDouble() * s.height);
      final speed = 8 + _rng.nextDouble() * 18;
      final ang = _rng.nextDouble() * pi * 2;
      final vel = Offset(cos(ang), sin(ang)) * speed;
      final r = 1.2 + _rng.nextDouble() * 1.9;
      return _Particle(pos: pos, vel: vel, radius: r);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final s = Size(c.maxWidth, c.maxHeight);
      if (_size != s) {
        _size = s;
        _ensureParticles(s);
      }

      return MouseRegion(
        onHover: (e) {
          _hasMouse = true;
          _mouse = e.localPosition;
        },
        onExit: (_) => _hasMouse = false,
        child: CustomPaint(
          painter: _MeshPainter(
            particles: _ps,
            time: _t,
            size: s,
            mouse: _mouse,
            hasMouse: _hasMouse,
            isDark: widget.isDark,
          ),
        ),
      );
    });
  }
}

class _Particle {
  Offset pos;
  Offset vel;
  final double radius;

  _Particle({required this.pos, required this.vel, required this.radius});
}

class _MeshPainter extends CustomPainter {
  final List<_Particle> particles;
  final double time;
  final Size size;
  final Offset mouse;
  final bool hasMouse;
  final bool isDark;

  _MeshPainter({
    required this.particles,
    required this.time,
    required this.size,
    required this.mouse,
    required this.hasMouse,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size _) {
    final rect = Offset.zero & size;

    final bgColors = isDark 
        ? const [Color(0xFF0F1118), Color(0xFF141625), Color(0xFF0B0D14)]
        : const [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFE2E8F0)];

    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: bgColors,
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    void glowBlob(Offset c, double r, Color col, double a) {
      final p = Paint()
        ..color = col.withOpacity(a)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);
      canvas.drawCircle(c, r, p);
    }

    final center = Offset(size.width * 0.55, size.height * 0.35);
    final wobble = Offset(sin(time * 0.5) * 40, cos(time * 0.45) * 30);

    glowBlob(center + wobble, 280, isDark ? const Color(0xFF8A4FFF) : const Color(0xFFA855F7), isDark ? 0.18 : 0.12);
    glowBlob(
      Offset(size.width * 0.25, size.height * 0.70) + Offset(cos(time * 0.35) * 35, sin(time * 0.32) * 28),
      240, isDark ? const Color(0xFF4895EF) : const Color(0xFF38BDF8), isDark ? 0.14 : 0.10,
    );

    Offset parallax = Offset.zero;
    if (hasMouse) {
      final dx = (mouse.dx / max(1.0, size.width) - 0.5) * 18;
      final dy = (mouse.dy / max(1.0, size.height) - 0.5) * 18;
      parallax = Offset(dx, dy);
    }

    final connectDist = min(size.width, size.height) * 0.15;
    final connectDist2 = connectDist * connectDist;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < particles.length; i++) {
      final a = particles[i];
      final ap = a.pos + parallax * 0.25;

      for (int j = i + 1; j < particles.length; j++) {
        final b = particles[j];
        final bp = b.pos + parallax * 0.25;

        final dx = ap.dx - bp.dx;
        final dy = ap.dy - bp.dy;
        final d2 = dx * dx + dy * dy;

        if (d2 < connectDist2) {
          final t = 1.0 - (sqrt(d2) / connectDist);
          linePaint.color = isDark 
              ? Colors.white.withOpacity(0.06 * t)
              : const Color(0xFF8A4FFF).withOpacity(0.15 * t);
          canvas.drawLine(ap, bp, linePaint);
        }
      }
    }

    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final pos = p.pos + parallax * 0.6;
      dotPaint.color = isDark ? Colors.white.withOpacity(0.12) : const Color(0xFF8A4FFF).withOpacity(0.25);
      canvas.drawCircle(pos, p.radius, dotPaint);
    }

    final vignetteColors = isDark
        ? [Colors.transparent, Colors.black.withOpacity(0.55)]
        : [Colors.transparent, Colors.white.withOpacity(0.4)];
        
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.15,
        colors: vignetteColors,
        stops: const [0.55, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  @override
  bool shouldRepaint(covariant _MeshPainter oldDelegate) => true;
}