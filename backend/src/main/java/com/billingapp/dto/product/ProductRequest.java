package com.billingapp.dto.product;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class ProductRequest {

    @NotBlank(message = "Product name is required")
    @Size(max = 200)
    private String productName;

    private String description;

    @NotNull(message = "Selling price is required")
    @Positive(message = "Selling price must be positive")
    private BigDecimal sellingPrice;

    private BigDecimal costPrice;
    private String sku;
    private String barcode;
    private String unit = "pcs";
    private Boolean trackInventory = true;
    private Integer currentStock = 0;
    private Integer lowStockAlert = 10;
    private String imageUrl;
    private Long categoryId;
}
