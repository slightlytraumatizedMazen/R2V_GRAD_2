import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool isSender;
  final String time;
  final bool isAttachment;
  final String? fileName;
  final String? fileSize;
  final bool isAISuggestion;

  ChatMessage({
    required this.text,
    required this.isSender,
    required this.time,
    this.isAttachment = false,
    this.fileName,
    this.fileSize,
    this.isAISuggestion = false,
  });
}

class WorkspaceChatPane extends StatefulWidget {
  const WorkspaceChatPane({super.key});

  @override
  State<WorkspaceChatPane> createState() => _WorkspaceChatPaneState();
}

class _WorkspaceChatPaneState extends State<WorkspaceChatPane> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "The lighting in the previous draft was great, but we need the neon tubes to have more volumetric scatter. Can you check the .blend file I just uploaded?",
      isSender: false,
      time: "10:42 AM",
    ),
    ChatMessage(
      text: "",
      isSender: false,
      time: "10:43 AM",
      isAttachment: true,
      fileName: "scene_v04_lighting.blend",
      fileSize: "42.8 MB • Blender Project",
    ),
    ChatMessage(
      text: "",
      isSender: true,
      time: "10:44 AM",
      isAISuggestion: true,
    ),
    ChatMessage(
      text: "Got it. Working on the volumetric density now. Will push the modeling milestone for approval in an hour.",
      isSender: true,
      time: "10:45 AM",
    ),
  ];

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final now = TimeOfDay.now();
    final timeStr = "${now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod}:${now.minute.toString().padLeft(2, '0')} ${now.period == DayPeriod.am ? 'AM' : 'PM'}";

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isSender: true,
        time: timeStr,
      ));
      _isTyping = true;
    });

    _msgController.clear();
    _scrollToBottom();

    // Mock Response Generator
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: "Looks excellent. The scatter values map perfectly! Let's submit this milestone.",
          isSender: false,
          time: timeStr, 
        ));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F0E15),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=150&auto=format&fit=crop",
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "joun",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "Senior 3D Artist",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFF9CA3AF),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.videocam_outlined, color: Colors.white, size: 18),
                  label: const Text(
                    "Start Video Meeting",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    side: BorderSide(color: Colors.white.withOpacity(0.15)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(32),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }

                final msg = _messages[index];
                if (msg.isAISuggestion) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _buildAISuggestion(),
                  );
                } else if (msg.isAttachment) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _buildAttachmentBubble(
                      fileName: msg.fileName ?? "",
                      fileSize: msg.fileSize ?? "",
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildMessageBubble(
                      isSender: msg.isSender,
                      text: msg.text,
                      time: msg.time,
                    ),
                  );
                }
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: Color(0xFF9CA3AF)),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.view_in_ar_outlined, color: Color(0xFF9CA3AF)),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1825),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _msgController,
                                style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                                decoration: const InputDecoration(
                                  hintText: "Type a message or drop .obj/.fbx files...",
                                  hintStyle: TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                  ),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: _sendMessage,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFA855F7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 104),
                  child: Text(
                    "ACCEPTS: .OBJ, .FBX, .BLEND, .GLTF",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1C2A), // Matches receiver color scheme
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: const Text(
          "Marcus Thorne is typing...",
          style: TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFF9CA3AF),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble({
    required bool isSender,
    required String text,
    required String time,
  }) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSender ? const Color(0xFF1A1825) : const Color(0xFF1E1C2A),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isSender ? 16 : 4),
              bottomRight: Radius.circular(isSender ? 4 : 16),
            ),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment:
                    isSender ? Alignment.bottomRight : Alignment.bottomLeft,
                child: Text(
                  time,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF6B7280),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentBubble({
    required String fileName,
    required String fileSize,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1C2A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFA855F7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.view_in_ar, color: Color(0xFFA855F7), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fileSize,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF9CA3AF),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.file_download_outlined, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAISuggestion() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_rounded,
                color: Color(0xFFA855F7), size: 16),
            const SizedBox(width: 10),
            const Text(
              "Suggesting a Revision Phase?",
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF9CA3AF),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Generate Offer",
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}