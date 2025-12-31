package com.billingapp.dto.customer;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CustomerResponse {

    private Long id;
    private String customerName;
    private String phoneNumber;
    private String email;
    private String address;
    private String gstNumber;
    private String notes;
    private BigDecimal totalPurchases;
    private Integer totalInvoices;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
