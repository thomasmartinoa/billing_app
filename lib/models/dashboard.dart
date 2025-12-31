class DashboardStats {
  final int totalCustomers;
  final int totalProducts;
  final int totalInvoices;
  final int lowStockProducts;
  final double totalSales;
  final double todaySales;
  final double thisMonthSales;
  final int pendingInvoices;
  final int paidInvoices;

  DashboardStats({
    this.totalCustomers = 0,
    this.totalProducts = 0,
    this.totalInvoices = 0,
    this.lowStockProducts = 0,
    this.totalSales = 0,
    this.todaySales = 0,
    this.thisMonthSales = 0,
    this.pendingInvoices = 0,
    this.paidInvoices = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalCustomers: json['totalCustomers'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      totalInvoices: json['totalInvoices'] ?? 0,
      lowStockProducts: json['lowStockProducts'] ?? 0,
      totalSales: (json['totalSales'] ?? 0).toDouble(),
      todaySales: (json['todaySales'] ?? 0).toDouble(),
      thisMonthSales: (json['thisMonthSales'] ?? 0).toDouble(),
      pendingInvoices: json['pendingInvoices'] ?? 0,
      paidInvoices: json['paidInvoices'] ?? 0,
    );
  }
}

class PagedResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;

  PagedResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PagedResponse(
      content: (json['content'] as List?)
          ?.map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList() ?? [],
      page: json['page'] ?? 0,
      size: json['size'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
    );
  }
}
