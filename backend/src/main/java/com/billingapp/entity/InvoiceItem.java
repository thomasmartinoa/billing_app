package com.billingapp.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "invoice_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InvoiceItem extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "invoice_id", nullable = false)
    private Invoice invoice;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(name = "product_name")
    private String productName;

    @Column(name = "description")
    private String description;

    @NotNull
    @Positive
    @Column(name = "quantity")
    private Integer quantity;

    @Column(name = "unit")
    private String unit;

    @NotNull
    @Positive
    @Column(name = "unit_price", precision = 12, scale = 2)
    private BigDecimal unitPrice;

    @Column(name = "discount_amount", precision = 12, scale = 2)
    private BigDecimal discountAmount = BigDecimal.ZERO;

    @Column(name = "line_total", precision = 12, scale = 2)
    private BigDecimal lineTotal = BigDecimal.ZERO;

    @PrePersist
    @PreUpdate
    public void calculateLineTotal() {
        BigDecimal total = unitPrice.multiply(BigDecimal.valueOf(quantity));
        this.lineTotal = total.subtract(discountAmount != null ? discountAmount : BigDecimal.ZERO);
    }
}
