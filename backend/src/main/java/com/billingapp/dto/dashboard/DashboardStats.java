package com.billingapp.dto.dashboard;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStats {

    private long totalCustomers;
    private long totalProducts;
    private long totalInvoices;
    private long lowStockProducts;
    private BigDecimal totalSales;
    private BigDecimal todaySales;
    private BigDecimal thisMonthSales;
    private long pendingInvoices;
    private long paidInvoices;
}
