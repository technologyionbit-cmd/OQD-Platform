/// A company (organization) as listed on the Companies page.
class Company {
  const Company({
    required this.id,
    required this.name,
    required this.registrationNumber,
    required this.verificationStatus,
    required this.ownerName,
    required this.ownerEmail,
    required this.membersCount,
    required this.createdAt,
    this.ownerPhone,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>;
    return Company(
      id: json['id'] as String,
      name: json['name'] as String,
      registrationNumber: json['commercialRegistrationNumber'] as String,
      verificationStatus: json['verificationStatus'] as String,
      ownerName: owner['fullName'] as String,
      ownerEmail: owner['email'] as String,
      ownerPhone: owner['phone'] as String?,
      membersCount: (json['membersCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final String name;
  final String registrationNumber;

  /// `unverified` | `pending` | `verified` | `rejected`
  final String verificationStatus;
  final String ownerName;
  final String ownerEmail;
  final String? ownerPhone;
  final int membersCount;
  final DateTime createdAt;

  /// Only these can be approved or rejected.
  bool get canDecide => verificationStatus == 'unverified' || verificationStatus == 'pending';
}

class CompaniesQuery {
  const CompaniesQuery({this.page = 1, this.limit = 20, this.sort = 'createdAt', this.ascending = false, this.search = '', this.verification});

  final int page;
  final int limit;
  final String sort;
  final bool ascending;
  final String search;
  final String? verification;

  CompaniesQuery copyWith({int? page, int? limit, String? sort, bool? ascending, String? search, String? Function()? verification}) => CompaniesQuery(
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
