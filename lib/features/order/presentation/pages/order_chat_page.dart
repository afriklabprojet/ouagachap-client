import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/order_chat_model.dart';
import '../bloc/order_chat_bloc.dart';

/// Page de chat entre le client et le coursier pour une commande
class OrderChatPage extends StatefulWidget {
  final String orderUuid;
  final String? courierName;

  const OrderChatPage({super.key, required this.orderUuid, this.courierName});

  @override
  State<OrderChatPage> createState() => _OrderChatPageState();
}

class _OrderChatPageState extends State<OrderChatPage>
    with WidgetsBindingObserver {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<OrderChatBloc>().add(LoadOrderChat(widget.orderUuid));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Au retour en premier plan, rafraîchir une fois pour rattraper les
    // messages éventuellement manqués pendant l'inactivité (WS déconnecté).
    if (state == AppLifecycleState.resumed) {
      context.read<OrderChatBloc>().add(const RefreshChat());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    context.read<OrderChatBloc>().add(SendOrderMessage(text));
    _messageController.clear();
    _focusNode.requestFocus();

    // Scroller vers le bas
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _callCourier(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Liste des messages
          Expanded(
            child: BlocConsumer<OrderChatBloc, OrderChatState>(
              listener: (context, state) {
                if (state is OrderChatReady) {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted) _scrollToBottom();
                  });
                }
              },
              builder: (context, state) {
                if (state is OrderChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is OrderChatError) {
                  return _buildErrorState(state.message);
                }

                if (state is OrderChatReady) {
                  if (state.messages.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildMessageList(state.messages);
                }

                return const SizedBox();
              },
            ),
          ),

          // Champ de saisie
          _buildInputField(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 1,
      title: BlocBuilder<OrderChatBloc, OrderChatState>(
        buildWhen: (p, c) {
          final pName = p is OrderChatReady ? p.chat.courierName : null;
          final cName = c is OrderChatReady ? c.chat.courierName : null;
          return pName != cName;
        },
        builder: (context, state) {
          String name = widget.courierName ?? 'Coursier';
          String? phone;

          if (state is OrderChatReady) {
            name = state.chat.courierName;
            phone = state.chat.courierPhone;
          }

          return Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'C',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (phone != null)
                      Text(
                        phone,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        // Bouton d'appel
        BlocBuilder<OrderChatBloc, OrderChatState>(
          buildWhen: (p, c) {
            final pPhone = p is OrderChatReady ? p.chat.courierPhone : null;
            final cPhone = c is OrderChatReady ? c.chat.courierPhone : null;
            return pPhone != cPhone;
          },
          builder: (context, state) {
            if (state is OrderChatReady && state.chat.courierPhone != null) {
              return IconButton(
                icon: const Icon(Icons.phone, color: AppColors.primary),
                onPressed: () => _callCourier(state.chat.courierPhone!),
                tooltip: 'Appeler le coursier',
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildMessageList(List<OrderChatMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isMe = !msg.isCourier; // Client = pas coursier
        final showDate =
            index == 0 ||
            !_isSameDay(messages[index - 1].createdAt, msg.createdAt);

        return Column(
          children: [
            if (showDate) _buildDateSeparator(msg.createdAt),
            _buildMessageBubble(msg, isMe),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    String label;
    if (_isSameDay(date, now)) {
      label = "Aujourd'hui";
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      label = 'Hier';
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(OrderChatMessage msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Image si présente
            if (msg.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: msg.imageUrl!,
                  width: 200,
                  fit: BoxFit.cover,
                  memCacheWidth:
                      400, // 2x pour Retina, évite OOM sur gros fichiers
                  placeholder: (context, url) => Container(
                    width: 200,
                    height: 100,
                    color: Colors.grey[200],
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 200,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
              if (msg.message != null && msg.message!.isNotEmpty)
                const SizedBox(height: 6),
            ],
            // Texte du message
            if (msg.message != null && msg.message!.isNotEmpty)
              Text(
                msg.message!,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
              ),
            const SizedBox(height: 4),
            // Heure + statut
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isMe ? Colors.white70 : Colors.grey[500],
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: msg.isRead ? Colors.lightBlueAccent : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return BlocBuilder<OrderChatBloc, OrderChatState>(
      buildWhen: (p, c) {
        final pSending = p is OrderChatReady && p.isSending;
        final cSending = c is OrderChatReady && c.isSending;
        return pSending != cSending;
      },
      builder: (context, state) {
        final isSending = state is OrderChatReady && state.isSending;

        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 8,
            top: 8,
            bottom: MediaQuery.of(context).padding.bottom + 8,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Écrire un message...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: isSending ? null : _sendMessage,
                  icon: isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aucun message',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Envoyez un message à votre coursier',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<OrderChatBloc>().add(
              LoadOrderChat(widget.orderUuid),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
