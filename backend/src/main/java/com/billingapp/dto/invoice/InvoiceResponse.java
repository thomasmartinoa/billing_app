package com.billingapp.dto.invoice;

import com.billingapp.entity.Invoice;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class InvoiceResponse {

    private Long id;
    private String invoiceNumber;
    private LocalDateTime invoiceDate;
    private LocalDateTime dueDate;

    private CustomerInfo customer;
    private List<InvoiceItemResponse> items;

    private BigDecimal subtotal;
    private BigDecimal discountAmount;
    private BigDecimal discountPercentage;
    private BigDecimal taxRate;
    private BigDecimal taxAmount;
    private BigDecimal totalAmount;
    private BigDecimal paidAmount;
    private BigDecimal balanceDue;

    private Invoice.PaymentStatus paymentStatus;
    private Invoice.PaymentMethod paymentMethod;
    private String notes;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CustomerInfo {
        private Long id;
        private String customerName;
        private String phoneNumber;
        private String email;
        private String address;
        private String gstNumber;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class InvoiceItemResponse {
        private Long id;
        private Long productId;
        private String productName;
        private String description;
        private Integer quantity;
        private String unit;
        private BigDecimal unitPrice;
        private BigDecimal discountAmount;
        private BigDecimal lineTotal;
    }
}
