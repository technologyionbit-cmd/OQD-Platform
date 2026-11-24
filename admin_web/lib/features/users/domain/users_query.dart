/// What the admin asked of the users list. The server does the paging,
/// sorting and filtering; this is just the request.
class UsersQuery {
  const UsersQuery({
    this.page = 1,
    this.limit = 20,
    this.sort = 'createdAt',
    this.ascending = false,
    this.search = '',
    this.role,
    this.status,
    this.deleted = 'exclude',
    this.createdFrom,
    this.createdTo,
  });

  final int page;
  final int limit;
  final String sort;
  final bool ascending;
  final String search;
  final String? role;
  final String? status;

  /// `exclude` | `only` | `include`
  final String deleted;

  /// Whole days (local). [createdTo] is inclusive: the request sends the
  /// start of the following day.
  final DateTime? createdFrom;
  final DateTime? createdTo;

  UsersQuery copyWith({
    int? page,
    int? limit,
    String? sort,
    bool? ascending,
    String? search,
    String? Function()? role,
    String? Function()? status,
    String? deleted,
    DateTime? Function()? createdFrom,
    DateTime? Function()? createdTo,
  }) {
    return UsersQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sort: sort ?? this.sort,
      ascending: ascending ?? this.ascending,
      search: search ?? this.search,
      role: role != null ? role() : this.role,
      status: status != null ? status() : this.status,
      deleted: deleted ?? this.deleted,
      createdFrom: createdFrom != null ? createdFrom() : this.createdFrom,
      createdTo: createdTo != null ? createdTo() : this.createdTo,
    );
  }

  bool get hasFilters => search.isNotEmpty || role != null || status != null || deleted != 'exclude' || createdFrom != null || createdTo != null;

  /// Query string for `GET /admin/users`. [paged] false drops page/limit
  /// (used by the CSV export, which takes every match).
  Map<String, dynamic> toParams({bool paged = true}) {
    return {
      if (paged) 'page': page,
      if (paged) 'limit': limit,
      'sort': sort,
      'order': ascending ? 'asc' : 'desc',
      if (search.isNotEmpty) 'q': search,
      if (role != null) 'role': role,
      if (status != null) 'status': status,
      'deleted': deleted,
      if (createdFrom != null) 'createdFrom': DateTime(createdFrom!.year, createdFrom!.month, createdFrom!.day).toUtc().toIso8601String(),
      if (createdTo != null) 'createdTo': DateTime(createdTo!.year, createdTo!.month, createdTo!.day + 1).toUtc().toIso8601String(),
    };
  }
}
