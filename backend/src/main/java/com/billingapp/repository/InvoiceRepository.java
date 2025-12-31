package com.billingapp.repository;

import com.billingapp.entity.Invoice;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface InvoiceRepository extends JpaRepository<Invoice, Long> {

    Page<Invoice> findByShopIdAndIsActiveTrue(Long shopId, Pageable pageable);

    Optional<Invoice> findByIdAndShopId(Long id, Long shopId);

    Optional<Invoice> findByInvoiceNumberAndShopId(String invoiceNumber, Long shopId);

    Page<Invoice> findByShopIdAndPaymentStatusAndIsActiveTrue(
            Long shopId, Invoice.PaymentStatus status, Pageable pageable);

    List<Invoice> findByCustomerIdAndIsActiveTrue(Long customerId);

    @Query("SELECT i FROM Invoice i WHERE i.shop.id = :shopId AND i.isActive = true " +
           "AND (LOWER(i.invoiceNumber) LIKE LOWER(CONCAT('%', :search, '%')) " +
           "OR LOWER(i.customer.customerName) LIKE LOWER(CONCAT('%', :search, '%')))")
    Page<Invoice> searchInvoices(Long shopId, String search, Pageable pageable);

    @Query("SELECT COUNT(i) FROM Invoice i WHERE i.shop.id = :shopId AND i.isActive = true")
    long countByShopId(Long shopId);

    @Query("SELECT COALESCE(SUM(i.totalAmount), 0) FROM Invoice i " +
           "WHERE i.shop.id = :shopId AND i.paymentStatus = 'PAID' AND i.isActive = true")
    BigDecimal getTotalSales(Long shopId);

    @Query("SELECT COALESCE(SUM(i.totalAmount), 0) FROM Invoice i " +
           "WHERE i.shop.id = :shopId AND i.isActive = true " +
           "AND i.invoiceDate BETWEEN :startDate AND :endDate")
    BigDecimal getSalesBetweenDates(Long shopId, LocalDateTime startDate, LocalDateTime endDate);

    @Query("SELECT i FROM Invoice i WHERE i.shop.id = :shopId AND i.isActive = true " +
           "AND i.paymentStatus = 'PENDING' AND i.dueDate < :now")
    List<Invoice> findOverdueInvoices(Long shopId, LocalDateTime now);

    @Query("SELECT i FROM Invoice i LEFT JOIN FETCH i.items WHERE i.id = :id AND i.shop.id = :shopId")
    Optional<Invoice> findByIdWithItems(Long id, Long shopId);
}
