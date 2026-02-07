import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/lottie_animations.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/form_fields.dart';
import '../../domain/entities/faq.dart';
import '../bloc/support_bloc.dart';
import '../bloc/support_event.dart';
import '../bloc/support_state.dart';

class FaqTab extends StatefulWidget {
  const FaqTab({super.key});

  @override
  State<FaqTab> createState() => _FaqTabState();
}

class _FaqTabState extends State<FaqTab> {
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _expandedFaqs = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher une question...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        context.read<SupportBloc>().add(const SearchFaqs(''));
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              context.read<SupportBloc>().add(SearchFaqs(value));
              setState(() {});
            },
          ),
        ),

        // Category Chips
        BlocBuilder<SupportBloc, SupportState>(
          buildWhen: (prev, curr) => prev.selectedFaqCategory != curr.selectedFaqCategory,
          builder: (context, state) {
            return Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: FaqCategories.all.entries.map((entry) {
                  final isSelected = state.selectedFaqCategory == entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        entry.value,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        context.read<SupportBloc>().add(ChangeFaqCategory(entry.key));
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),

        // FAQ List
        Expanded(
          child: BlocBuilder<SupportBloc, SupportState>(
            buildWhen: (prev, curr) =>
                prev.faqs != curr.faqs || prev.faqsLoading != curr.faqsLoading,
            builder: (context, state) {
              if (state.faqsLoading) {
                return const AnimatedLoadingWidget(
                  message: 'Chargement des FAQs...',
                );
              }

              if (state.faqs.isEmpty) {
                return AnimatedEmptyWidget(
                  title: 'Aucune FAQ trouvée',
                  subtitle: 'Essayez une autre recherche ou catégorie',
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<SupportBloc>().add(LoadFaqs());
                },
                color: AppColors.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.faqs.length,
                  itemBuilder: (context, index) {
                    final faq = state.faqs[index];
                    final isExpanded = _expandedFaqs.contains(faq.id);
                    
                    return _FaqCard(
                      faq: faq,
                      isExpanded: isExpanded,
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedFaqs.remove(faq.id);
                          } else {
                            _expandedFaqs.add(faq.id);
                            context.read<SupportBloc>().add(ViewFaq(faq.id));
                          }
                        });
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FaqCard extends StatelessWidget {
  final Faq faq;
  final bool isExpanded;
  final VoidCallback onTap;

  const _FaqCard({
    required this.faq,
    required this.isExpanded,
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        faq.categoryLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  faq.question,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      faq.answer,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                  ),
                  crossFadeState:
                      isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
