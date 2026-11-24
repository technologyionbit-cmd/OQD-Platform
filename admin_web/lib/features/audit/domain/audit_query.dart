/// What the admin asked of the audit list.
class AuditQuery {
  const AuditQuery({
    this.page = 1,
    this.limit = 20,
    this.ascending = false,
    this.search = '',
    this.action = '',
    this.entityType,
    this.outcome,
    this.from,
    this.to,
  });

  final int page;
  final int limit;
  final bool ascending;
  final String search;
  final String action;
  final String? entityType;

  /// `success` | `failure`
  final String? outcome;
  final DateTime? from;

  /// Inclusive day; the request sends the start of the next one.
  final DateTime? to;

  AuditQuery copyWith({
    int? page,
    int? limit,
    bool? ascending,
    String? search,
    String? action,
    String? Function()? entityType,
    String? Function()? outcome,
    DateTime? Function()? from,
    DateTime? Function()? to,
  }) {
    return AuditQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      ascending: ascending ?? this.ascending,
      search: search ?? this.search,
      action: action ?? this.action,
      entityType: entityType != null ? entityType() : this.entityType,
      outcome: outcome != null ? outcome() : this.outcome,
      from: from != null ? from() : this.from,
      to: to != null ? to() : this.to,
    );
  }

  bool get hasFilters => search.isNotEmpty || action.isNotEmpty || entityType != null || outcome != null || from != null || to != null;

  Map<String, dynamic> toParams() => {
        'page': page,
        'limit': limit,
        'sort': 'createdAt',
        'order': ascending ? 'asc' : 'desc',
        if (search.isNotEmpty) 'q': search,
        if (action.isNotEmpty) 'action': action,
        if (entityType != null) 'entityType': entityType,
        if (outcome != null) 'outcome': outcome,
        if (from != null) 'from': DateTime(from!.year, from!.month, from!.day).toUtc().toIso8601String(),
        if (to != null) 'to': DateTime(to!.year, to!.month, to!.day + 1).toUtc().toIso8601String(),
      };
}
