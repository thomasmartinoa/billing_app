package com.billingapp.dto.product;

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
public class ProductResponse {

    private Long id;
    private String productName;
    private String description;
    private BigDecimal sellingPrice;
    private BigDecimal costPrice;
    private String sku;
    private String barcode;
    private String unit;
    private Boolean trackInventory;
    private Integer currentStock;
    private Integer lowStockAlert;
    private Boolean isLowStock;
    private String imageUrl;
    private Long categoryId;
    private String categoryName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
