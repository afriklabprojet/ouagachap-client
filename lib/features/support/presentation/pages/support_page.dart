import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/faq.dart';
import '../../domain/entities/contact_info.dart';
import '../../domain/entities/support_chat.dart';
import '../../domain/entities/complaint.dart';
import '../bloc/support_bloc.dart';
import '../bloc/support_event.dart';
import '../bloc/support_state.dart';
import '../widgets/faq_tab.dart';
import '../widgets/chat_tab.dart';
import '../widgets/complaints_tab.dart';
import '../widgets/contact_tab.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Charger les données initiales
    final bloc = context.read<SupportBloc>();
    bloc.add(LoadContactInfo());
    bloc.add(LoadFaqs());
    bloc.add(LoadChats());
    bloc.add(LoadComplaints());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Aide & Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabs: [
            const Tab(icon: Icon(Icons.help_outline, size: 20), text: 'FAQ'),
            BlocBuilder<SupportBloc, SupportState>(
              buildWhen: (prev, curr) => prev.chats != curr.chats,
              builder: (context, state) {
                final unread = state.chats.fold(0, (sum, c) => sum + c.unreadCount);
                return Tab(
                  icon: Badge(
                    isLabelVisible: unread > 0,
                    label: Text('$unread', style: const TextStyle(fontSize: 10)),
                    child: const Icon(Icons.chat_bubble_outline, size: 20),
                  ),
                  text: 'Chat',
                );
              },
            ),
            BlocBuilder<SupportBloc, SupportState>(
              buildWhen: (prev, curr) => prev.complaints != curr.complaints,
              builder: (context, state) {
                final unread = state.complaints.fold(0, (sum, c) => sum + c.unreadCount);
                return Tab(
                  icon: Badge(
                    isLabelVisible: unread > 0,
                    label: Text('$unread', style: const TextStyle(fontSize: 10)),
                    child: const Icon(Icons.report_problem_outlined, size: 20),
                  ),
                  text: 'Tickets',
                );
              },
            ),
            const Tab(icon: Icon(Icons.phone_outlined, size: 20), text: 'Contact'),
          ],
        ),
      ),
      body: BlocListener<SupportBloc, SupportState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () => context.read<SupportBloc>().add(ClearSupportError()),
                ),
              ),
            );
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: const [
            FaqTab(),
            ChatTab(),
            ComplaintsTab(),
            ContactTab(),
          ],
        ),
      ),
    );
  }
}
