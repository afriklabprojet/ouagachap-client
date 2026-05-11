import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/lottie_animations.dart';
import '../bloc/support_bloc.dart';
import '../bloc/support_event.dart';
import '../bloc/support_state.dart';
import 'complaints/complaint_details_sheet.dart';
import 'complaints/complaint_list_item.dart';
import 'complaints/create_complaint_sheet.dart';

class ComplaintsTab extends StatefulWidget {
  const ComplaintsTab({super.key});

  @override
  State<ComplaintsTab> createState() => _ComplaintsTabState();
}

class _ComplaintsTabState extends State<ComplaintsTab> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupportBloc, SupportState>(
      buildWhen: (p, c) =>
          p.complaints != c.complaints ||
          p.complaintsLoading != c.complaintsLoading ||
          p.currentComplaint != c.currentComplaint ||
          p.sendingMessage != c.sendingMessage ||
          p.complaintMessages != c.complaintMessages,
      builder: (context, state) {
        if (state.currentComplaint != null) {
          return ComplaintDetailsSheet(
            complaint: state.currentComplaint!,
            messages: state.complaintMessages,
            isLoading: state.complaintsLoading,
            sendingMessage: state.sendingMessage,
            onBack: () {
              context.read<SupportBloc>().add(LoadComplaints());
            },
          );
        }
        return _buildComplaintsList(context, state);
      },
    );
  }

  Widget _buildComplaintsList(BuildContext context, SupportState state) {
    if (state.complaintsLoading) {
      return const AnimatedLoadingWidget(
        message: 'Chargement des réclamations...',
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _showCreateComplaintDialog(context),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Nouvelle réclamation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: state.complaints.isEmpty
              ? const AnimatedEmptyWidget(
                  title: 'Aucune réclamation',
                  subtitle:
                      'Vous n\'avez pas de réclamations en cours.\nTout va bien !',
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<SupportBloc>().add(LoadComplaints());
                  },
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.complaints.length,
                    itemBuilder: (context, index) {
                      final complaint = state.complaints[index];
                      return ComplaintListItem(
                        complaint: complaint,
                        onTap: () {
                          context.read<SupportBloc>().add(
                            LoadComplaintDetails(complaint.id),
                          );
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  void _showCreateComplaintDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<SupportBloc>(),
        child: const CreateComplaintSheet(),
      ),
    );
  }
}
