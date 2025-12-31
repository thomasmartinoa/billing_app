package com.billingapp.dto.invoice;

import com.billingapp.entity.Invoice;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class InvoiceRequest {

    private Long customerId;

    @NotNull(message = "Invoice date is required")
    private LocalDateTime invoiceDate;

    private LocalDateTime dueDate;

    @NotEmpty(message = "At least one item is required")
    @Valid
    private List<InvoiceItemRequest> items;

    private BigDecimal discountAmount = BigDecimal.ZERO;
    private BigDecimal discountPercentage = BigDecimal.ZERO;

    private Invoice.PaymentMethod paymentMethod;
    private Boolean markAsPaid = false;
    private String notes;

    @Data
    public static class InvoiceItemRequest {
        @NotNull(message = "Product ID is required")
        private Long productId;

        @NotNull(message = "Quantity is required")
        private Integer quantity;

        private BigDecimal unitPrice;
        private BigDecimal discountAmount = BigDecimal.ZERO;
    }
}
