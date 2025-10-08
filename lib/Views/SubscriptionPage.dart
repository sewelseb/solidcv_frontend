import 'package:flutter/material.dart';
import 'package:solid_cv/business_layer/IUserBLL.dart';
import 'package:solid_cv/business_layer/UserBLL.dart';
import 'package:solid_cv/models/User.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:solid_cv/Views/utils/PremiumHelper.dart';
import 'package:solid_cv/Views/utils/FormatDate.dart';
import 'package:solid_cv/Views/widgets/SubscriptionWidgets/PlansView.dart';
import 'package:solid_cv/Views/widgets/SubscriptionWidgets/ActiveSubscriptionView.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final IUserBLL _userBll = UserBll();
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _userBll.getCurrentUser();
  }

  bool _isPremiumActive(User user) =>
      PremiumHelper.isPremiumActive(user.premiumSubscriptionDate);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.subscriptionTitle),
      ),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data!;
          final isActive = _isPremiumActive(user);

          if (isActive) {
            return ActiveSubscriptionView(
              renewalDateText: user.premiumSubscriptionDate != null
                  ? FormatDate().formatDateForPremiumDate(
                      context, user.premiumSubscriptionDate!)
                  : '-',
            );
          }

          return PlansView(theme: theme);
        },
      ),
    );
  }
}
