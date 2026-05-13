import re

with open(r"d:\PROJEK\projekrun\simflutter\manajemen_tahsin_app\lib\features\dashboard\presentation\screens\dashboard_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Remove _StatCard class
content = re.sub(r'class _StatCard extends StatelessWidget \{.*?\n\}\n', '', content, flags=re.DOTALL)

# Remove _DashboardBottomTabs class and state
content = re.sub(r'class _DashboardBottomTabs extends StatefulWidget \{.*?\n\}\n', '', content, flags=re.DOTALL)
content = re.sub(r'class _DashboardBottomTabsState extends State<_DashboardBottomTabs> with SingleTickerProviderStateMixin \{.*?\n\}\n', '', content, flags=re.DOTALL)
# Wait, what if the state goes until the very end of the file? Yes it does. The regex `.*?\n\}\n` might capture it if the file ends with a newline. But let's check.

# Add imports
imports = """import 'package:manajemen_tahsin_app/core/widgets/state_widgets.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:manajemen_tahsin_app/features/dashboard/presentation/widgets/dashboard_bottom_tabs.dart';
"""
content = content.replace("import 'package:manajemen_tahsin_app/core/widgets/connection_status_badge.dart';", "import 'package:manajemen_tahsin_app/core/widgets/connection_status_badge.dart';\n" + imports)

# Replace _StatCard with StatCard
content = content.replace("_StatCard(", "StatCard(")

# Replace _DashboardBottomTabs with DashboardBottomTabs
content = content.replace("_DashboardBottomTabs(", "DashboardBottomTabs(")

# Replace Loading State
loading_replacement = """            if (state is DashboardLoading || state is DashboardInitial) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: SkeletonListWidget(itemCount: 5, itemHeight: 120),
              );
            }"""
content = re.sub(r'            if \(state is DashboardLoading \|\| state is DashboardInitial\) \{\s*return const Center\(\s*child: CircularProgressIndicator\(color: kHeaderColor\)\);\s*\}', loading_replacement, content)

# Replace Error State
error_replacement = """            if (state is DashboardError) {
              return ErrorStateWidget(
                message: state.message,
                onRetry: () => context.read<DashboardCubit>().fetchDashboard(forceRefresh: true),
              );
            }"""
content = re.sub(r'            if \(state is DashboardError\) \{\s*return Center\(\s*child: Column\(.*?\),\s*\);\s*\}', error_replacement, content, flags=re.DOTALL)

with open(r"d:\PROJEK\projekrun\simflutter\manajemen_tahsin_app\lib\features\dashboard\presentation\screens\dashboard_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)

print("Updated dashboard_screen.dart")
