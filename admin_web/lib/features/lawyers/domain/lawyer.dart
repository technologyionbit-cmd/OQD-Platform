/// A lawyer profile as listed on the Lawyers page.
class Lawyer {
  const Lawyer({
    required this.id,
    required this.fullName,
    required this.email,
    required this.barLicenseNumber,
    required this.yearsOfExperience,
    required this.rating,
    required this.reviewsCount,
    required this.verificationStatus,
    required this.specialties,
    required this.consultationsCount,
    required this.createdAt,
    this.phone,
    this.rejectionReason,
  });

  factory Lawyer.fromJson(Map<String, dynamic> json) => Lawyer(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        barLicenseNumber: json['barLicenseNumber'] as String,
        yearsOfExperience: (json['yearsOfExperience'] as num).toInt(),
        rating: (json['rating'] as num).toDouble(),
        reviewsCount: (json['reviewsCount'] as num).toInt(),
        verificationStatus: json['verificationStatus'] as String,
        rejectionReason: json['verificationRejectionReason'] as String?,
        specialties: [for (final s in json['specialties'] as List<dynamic>) s as String],
        consultationsCount: (json['consultationsCount'] as num).toInt(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String barLicenseNumber;
  final int yearsOfExperience;
  final double rating;
  final int reviewsCount;

  /// `unverified` | `pending` | `verified` | `rejected`
  final String verificationStatus;
  final String? rejectionReason;
  final List<String> specialties;
  final int consultationsCount;
  final DateTime createdAt;
}

/// What the admin asked of the lawyers list; the server does the work.
class LawyersQuery {
  const LawyersQuery({
    this.page = 1,
    this.limit = 20,
    this.sort = 'createdAt',
    this.ascending = false,
    this.search = '',
    this.verification,
  });

  final int page;
  final int limit;
  final String sort;
  final bool ascending;
  final String search;
  final String? verification;

  LawyersQuery copyWith({
    int? page,
    int? limit,
    String? sort,
    bool? ascending,
    String? search,
    String? Function()? verification,
  }) =>
      LawyersQuery(
        page: page ?? this.page,
        limit: limit ?? this.limit,
        sort: sort ?? this.sort,
        ascending: ascending ?? this.ascending,
        search: search ?? this.search,
        verification: verification != null ? verification() : this.verification,
      );

  bool get hasFilters => search.isNotEmpty || verification != null;

  Map<String, dynamic> toParams() => {
        'page': page,
        'limit': limit,
        'sort': sort,
        'order': ascending ? 'asc' : 'desc',
        if (search.isNotEmpty) 'q': search,
        if (verification != null) 'verification': verification,
      };
}
