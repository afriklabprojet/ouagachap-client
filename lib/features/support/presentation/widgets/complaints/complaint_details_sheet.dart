import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/status_mapper.dart';
import '../../../domain/entities/complaint.dart';
import '../../bloc/support_bloc.dart';
import '../../bloc/support_event.dart';
import 'complaint_info_row.dart';
import 'complaint_message_bubble.dart';

class ComplaintDetailsSheet extends StatefulWidget {
  final Complaint complaint;
  final List<ComplaintMessage> messages;
  final bool isLoading;
  final bool sendingMessage;
  final VoidCallback onBack;

  const ComplaintDetailsSheet({
    super.key,
    required this.complaint,
    required this.messages,
    required this.isLoading,
    required this.sendingMessage,
    required this.onBack,
  });

  @override
  State<ComplaintDetailsSheet> createState() => _ComplaintDetailsSheetState();
}

class _ComplaintDetailsSheetState extends State<ComplaintDetailsSheet> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: widget.onBack,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.complaint.subject,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    ComplaintInfoRow(
                      label: 'Ticket',
                      value: '#${widget.complaint.ticketNumber}',
                      isMono: true,
                    ),
                    const SizedBox(height: 8),
                    ComplaintInfoRow(
                      label: 'Type',
                      value: widget.complaint.typeLabel,
                    ),
                    const SizedBox(height: 8),
                    ComplaintInfoRow(
                      label: 'Statut',
                      value: widget.complaint.statusLabel,
                      valueColor: _getStatusColor(widget.complaint.status),
                    ),
                    if (widget.complaint.resolution != null) ...[
                      const SizedBox(height: 8),
                      ComplaintInfoRow(
                        label: 'Résolution',
                        value: widget.complaint.resolution!,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: widget.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.messages.length,
                  itemBuilder: (context, index) {
                    return ComplaintMessageBubble(
                      message: widget.messages[index],
                    );
                  },
                ),
        ),

        // Input
        if (widget.complaint.canReply) _buildMessageInput(context),
      ],
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ajouter un commentaire...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: widget.sendingMessage
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
                onPressed: widget.sendingMessage
                    ? null
                    : () {
                        final message = _messageController.text.trim();
                        if (message.isNotEmpty) {
                          context.read<SupportBloc>().add(
                            AddComplaintMessage(widget.complaint.id, message),
                          );
                          _messageController.clear();
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) =>
      ComplaintStatusMapper.getColor(status);
}
