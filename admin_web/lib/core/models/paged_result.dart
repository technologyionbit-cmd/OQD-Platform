/// One page of a server-paged list: `{ data: [...], meta: { page, limit,
/// total, totalPages } }`.
class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PagedResult.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic> row) parse) {
    final data = json['data'];
    final meta = json['meta'];
    if (data is! List<dynamic> || meta is! Map<String, dynamic>) {
      throw const FormatException('Malformed page response');
    }
    return PagedResult(
      items: [for (final row in data) parse(row as Map<String, dynamic>)],
      page: meta['page'] as int,
      limit: meta['limit'] as int,
      total: meta['total'] as int,
      totalPages: meta['totalPages'] as int,
    );
  }

  final List<T> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
}
