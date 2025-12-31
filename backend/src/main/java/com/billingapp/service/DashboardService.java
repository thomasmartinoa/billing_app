package com.billingapp.service;

import com.billingapp.dto.dashboard.DashboardStats;
import com.billingapp.entity.Invoice;
import com.billingapp.entity.Shop;
import com.billingapp.repository.CustomerRepository;
import com.billingapp.repository.InvoiceRepository;
import com.billingapp.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Service
@RequiredArgsConstructor
@Slf4j
public class DashboardService {

    private final CustomerRepository customerRepository;
    private final ProductRepository productRepository;
    private final InvoiceRepository invoiceRepository;
    private final ShopService shopService;

    @Transactional(readOnly = true)
    public DashboardStats getDashboardStats(Long userId) {
        Shop shop = shopService.getShopEntity(userId);
        Long shopId = shop.getId();

        // Get counts
        long totalCustomers = customerRepository.countByShopIdAndIsActiveTrue(shopId);
        long totalProducts = productRepository.countByShopIdAndIsActiveTrue(shopId);
        long totalInvoices = invoiceRepository.countByShopId(shopId);
        long lowStockProducts = productRepository.countLowStockProducts(shopId);

        // Get sales
        BigDecimal totalSales = invoiceRepository.getTotalSales(shopId);

        // Today's sales
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = LocalDate.now().atTime(LocalTime.MAX);
        BigDecimal todaySales = invoiceRepository.getSalesBetweenDates(shopId, startOfDay, endOfDay);

        // This month's sales
        LocalDateTime startOfMonth = LocalDate.now().withDayOfMonth(1).atStartOfDay();
        BigDecimal thisMonthSales = invoiceRepository.getSalesBetweenDates(shopId, startOfMonth, endOfDay);

        // Invoice stats by status
        long pendingInvoices = invoiceRepository
                .findByShopIdAndPaymentStatusAndIsActiveTrue(shopId, Invoice.PaymentStatus.PENDING, 
                        org.springframework.data.domain.Pageable.unpaged())
                .getTotalElements();
        
        long paidInvoices = invoiceRepository
                .findByShopIdAndPaymentStatusAndIsActiveTrue(shopId, Invoice.PaymentStatus.PAID, 
                        org.springframework.data.domain.Pageable.unpaged())
                .getTotalElements();

        return DashboardStats.builder()
                .totalCustomers(totalCustomers)
                .totalProducts(totalProducts)
                .totalInvoices(totalInvoices)
                .lowStockProducts(lowStockProducts)
                .totalSales(totalSales != null ? totalSales : BigDecimal.ZERO)
                .todaySales(todaySales != null ? todaySales : BigDecimal.ZERO)
                .thisMonthSales(thisMonthSales != null ? thisMonthSales : BigDecimal.ZERO)
                .pendingInvoices(pendingInvoices)
                .paidInvoices(paidInvoices)
                .build();
    }
}
