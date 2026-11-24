/// `GET /admin/dashboard/summary`, parsed.
class DashboardSummary {
  const DashboardSummary({
    required this.totalUsers,
    required this.usersByRole,
    required this.suspendedUsers,
    required this.newUsers7d,
    required this.pendingLawyers,
    required this.organizations,
    required this.pendingOrganizations,
    required this.upcomingConsultations,
    required this.consultationsByStatus,
    required this.totalContracts,
    required this.contractsByStatus,
    required this.signups,
    required this.consultationsSeries,
    required this.recentActivity,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> m(Object? v) => v! as Map<String, dynamic>;
    Map<String, int> counts(Object? v) => {for (final e in m(v).entries) e.key: (e.value as num).toInt()};
    List<int> series(Object? v) => [for (final p in v! as List<dynamic>) ((p as Map<String, dynamic>)['count'] as num).toInt()];

    final users = m(json['users']);
    final consultations = m(json['consultations']);
    final contracts = m(json['contracts']);
    final orgs = m(json['organizations']);
    final seriesJson = m(json['series']);
    return DashboardSummary(
      totalUsers: (users['total'] as num).toInt(),
      usersByRole: counts(users['byRole']),
      suspendedUsers: (users['suspended'] as num).toInt(),
      newUsers7d: (users['newLast7Days'] as num).toInt(),
      pendingLawyers: (m(json['lawyers'])['pendingReview'] as num).toInt(),
      organizations: (orgs['total'] as num).toInt(),
      pendingOrganizations: (orgs['pendingVerification'] as num).toInt(),
      upcomingConsultations: (consultations['upcoming'] as num).toInt(),
      consultationsByStatus: counts(consultations['byStatus']),
      totalContracts: (contracts['total'] as num).toInt(),
      contractsByStatus: counts(contracts['byStatus']),
      signups: series(seriesJson['signups']),
      consultationsSeries: series(seriesJson['consultations']),
      recentActivity: [for (final a in json['recentActivity'] as List<dynamic>) ActivityEntry.fromJson(a as Map<String, dynamic>)],
    );
  }

  final int totalUsers;
  final Map<String, int> usersByRole;
  final int suspendedUsers;
  final int newUsers7d;
  final int pendingLawyers;
  final int organizations;
  final int pendingOrganizations;
  final int upcomingConsultations;
  final Map<String, int> consultationsByStatus;
  final int totalContracts;
  final Map<String, int> contractsByStatus;

  /// Daily counts, oldest day first.
  final List<int> signups;
  final List<int> consultationsSeries;
  final List<ActivityEntry> recentActivity;
}

class ActivityEntry {
  const ActivityEntry({required this.id, required this.action, required this.createdAt, this.actorName});

  factory ActivityEntry.fromJson(Map<String, dynamic> json) => ActivityEntry(
        id: json['id'] as String,
        action: json['action'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        actorName: (json['actor'] as Map<String, dynamic>?)?['fullName'] as String?,
      );

  final String id;
  final String action;
  final DateTime createdAt;
  final String? actorName;
}
