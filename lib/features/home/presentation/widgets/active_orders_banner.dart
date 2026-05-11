import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../order/presentation/bloc/order_bloc.dart';
import '../../../order/presentation/bloc/order_state.dart';
import 'active_order_card.dart';

class ActiveOrdersBanner extends StatelessWidget {
  const ActiveOrdersBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      buildWhen: (p, c) {
        if (p is OrdersLoaded && c is OrdersLoaded) {
          final pActive = p.orders.where((o) => o.isActive).length;
          final cActive = c.orders.where((o) => o.isActive).length;
          return pActive != cActive || p.orders != c.orders;
        }
        return p.runtimeType != c.runtimeType;
      },
      builder: (context, state) {
        if (state is OrdersLoaded) {
          final activeOrders = state.orders.where((o) => o.isActive).toList();

          if (activeOrders.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.activeOrders,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(Routes.ordersHistory),
                      child: Text(context.l10n.translate('see_all')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: activeOrders.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    return ActiveOrderCard(order: activeOrders[index]);
                  },
                ),
              ),
            ],
          );
        }
        if (state is OrderLoading) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
