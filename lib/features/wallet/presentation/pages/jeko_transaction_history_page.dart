import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/lottie_animations.dart';
import '../../../../core/widgets/skeleton_loaders.dart';
import '../../data/datasources/jeko_payment_datasource.dart';
import '../bloc/jeko_payment_bloc.dart';
import '../bloc/jeko_payment_event.dart';
import '../bloc/jeko_payment_state.dart';

/// Page d'historique des transactions JEKO
class JekoTransactionHistoryPage extends StatefulWidget {
  const JekoTransactionHistoryPage({super.key});

  @override
  State<JekoTransactionHistoryPage> createState() =>
      _JekoTransactionHistoryPageState();
}

class _JekoTransactionHistoryPageState
    extends State<JekoTransactionHistoryPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<JekoPaymentBloc>().add(const LoadTransactionHistory());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<JekoPaymentBloc>().state;
      if (state.hasMoreHistory &&
          state.status != JekoPaymentStatus.loadingHistory) {
        context.read<JekoPaymentBloc>().add(
              LoadTransactionHistory(page: state.currentPage + 1),
            );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des paiements'),
        centerTitle: true,
      ),
      body: BlocBuilder<JekoPaymentBloc, JekoPaymentState>(
        builder: (context, state) {
          if (state.status == JekoPaymentStatus.loadingHistory &&
              state.transactionHistory.isEmpty) {
            return const SkeletonTransactionListLoader();
          }

          if (state.transactionHistory.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<JekoPaymentBloc>().add(
                    const LoadTransactionHistory(page: 1),
                  );
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.transactionHistory.length +
                  (state.hasMoreHistory ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.transactionHistory.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return SlideInWidget(
                  delay: Duration(milliseconds: 50 * (index % 10)),
                  child: _buildTransactionCard(state.transactionHistory[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return AnimatedEmptyWidget(
      title: 'Aucune transaction',
      subtitle: 'Vos transactions Mobile Money\napparaîtront ici',
    );
  }

  Widget _buildTransactionCard(JekoTransaction transaction) {
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
      child: InkWell(
        onTap: () => _showTransactionDetails(transaction),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône de la méthode de paiement
              _buildMethodIcon(transaction),
              const SizedBox(width: 12),

              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTransactionTitle(transaction),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.paymentMethodName,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(transaction.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              // Montant et statut
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    transaction.formattedAmount,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: transaction.isSuccessful
                          ? Colors.green
                          : transaction.isFailed
                              ? Colors.red
                              : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusBadge(transaction),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodIcon(JekoTransaction transaction) {
    final colorMap = {
      'wave': const Color(0xFF1DC3E8),
      'orange': const Color(0xFFFF6600),
      'mtn': const Color(0xFFFFCC00),
      'moov': const Color(0xFF0066CC),
      'djamo': const Color(0xFF6C5CE7),
    };

    final iconMap = {
      'wave': '🌊',
      'orange': '🟠',
      'mtn': '🟡',
      'moov': '🔵',
      'djamo': '💳',
    };

    final color = colorMap[transaction.paymentMethod] ?? Colors.grey;
    final icon = iconMap[transaction.paymentMethod] ?? '💰';

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(JekoTransaction transaction) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    if (transaction.isSuccessful) {
      backgroundColor = Colors.green.withValues(alpha: 0.1);
      textColor = Colors.green;
      icon = Icons.check_circle;
    } else if (transaction.isFailed) {
      backgroundColor = Colors.red.withValues(alpha: 0.1);
      textColor = Colors.red;
      icon = Icons.cancel;
    } else {
      backgroundColor = Colors.orange.withValues(alpha: 0.1);
      textColor = Colors.orange;
      icon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            transaction.statusLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getTransactionTitle(JekoTransaction transaction) {
    switch (transaction.type) {
      case 'wallet_recharge':
        return 'Recharge portefeuille';
      case 'order_payment':
        return 'Paiement commande';
      default:
        return 'Transaction';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return 'Il y a ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Il y a ${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays} jour${diff.inDays > 1 ? 's' : ''}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
  }

  void _showTransactionDetails(JekoTransaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Icône statut
            Icon(
              transaction.isSuccessful
                  ? Icons.check_circle
                  : transaction.isFailed
                      ? Icons.cancel
                      : Icons.hourglass_empty,
              size: 60,
              color: transaction.isSuccessful
                  ? Colors.green
                  : transaction.isFailed
                      ? Colors.red
                      : Colors.orange,
            ),
            const SizedBox(height: 12),

            // Montant
            Text(
              transaction.formattedAmount,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              transaction.statusLabel,
              style: TextStyle(
                fontSize: 16,
                color: transaction.isSuccessful
                    ? Colors.green
                    : transaction.isFailed
                        ? Colors.red
                        : Colors.orange,
              ),
            ),
            const SizedBox(height: 24),

            // Détails
            _buildDetailRow('Type', _getTransactionTitle(transaction)),
            _buildDetailRow('Méthode', transaction.paymentMethodName),
            _buildDetailRow('Référence', transaction.reference),
            if (transaction.fees > 0)
              _buildDetailRow('Frais', '${transaction.fees.toStringAsFixed(0)} ${transaction.currency}'),
            _buildDetailRow(
              'Date',
              DateFormat('dd/MM/yyyy à HH:mm').format(transaction.createdAt),
            ),
            if (transaction.executedAt != null)
              _buildDetailRow(
                'Exécuté le',
                DateFormat('dd/MM/yyyy à HH:mm').format(transaction.executedAt!),
              ),

            const SizedBox(height: 20),

            // Bouton fermer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Fermer'),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
