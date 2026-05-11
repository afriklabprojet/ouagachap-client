import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/utils/status_mapper.dart';
import '../../../domain/entities/complaint.dart';
import 'complaint_status_badge.dart';

class ComplaintListItem extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback onTap;

  const ComplaintListItem({
    super.key,
    required this.complaint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getStatusColor(complaint.status).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              _getTypeEmoji(complaint.type),
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                complaint.subject,
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (complaint.hasUnread)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '#${complaint.ticketNumber}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ComplaintStatusBadge(
                  label: complaint.statusLabel,
                  color: _getStatusColor(complaint.status),
                ),
                const SizedBox(width: 8),
                ComplaintStatusBadge(
                  label: complaint.priorityLabel,
                  color: _getPriorityColor(complaint.priority),
                  outlined: true,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(complaint.createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  String _getTypeEmoji(String type) {
    return switch (type) {
      'delivery_issue' => '🚚',
      'payment_issue' => '💰',
      'courier_behavior' => '👤',
      'app_bug' => '🐛',
      _ => '📋',
    };
  }

  Color _getStatusColor(String status) =>
      ComplaintStatusMapper.getColor(status);

  Color _getPriorityColor(String priority) {
    return switch (priority) {
      'low' => Colors.grey,
      'medium' => Colors.blue,
      'high' => Colors.orange,
      'urgent' => Colors.red,
      _ => Colors.grey,
    };
  }
}
