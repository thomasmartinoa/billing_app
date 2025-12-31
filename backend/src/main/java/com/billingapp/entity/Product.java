package com.billingapp.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "products")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Product extends BaseEntity {

    @NotBlank
    @Size(max = 200)
    @Column(name = "product_name")
    private String productName;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @NotNull
    @Positive
    @Column(name = "selling_price", precision = 12, scale = 2)
    private BigDecimal sellingPrice;

    @Column(name = "cost_price", precision = 12, scale = 2)
    private BigDecimal costPrice;

    @Column(name = "sku")
    private String sku;

    @Column(name = "barcode")
    private String barcode;

    @Column(name = "unit")
    private String unit = "pcs";

    @Column(name = "track_inventory")
    private Boolean trackInventory = true;

    @Column(name = "current_stock")
    private Integer currentStock = 0;

    @Column(name = "low_stock_alert")
    private Integer lowStockAlert = 10;

    @Column(name = "image_url")
    private String imageUrl;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private Category category;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shop_id", nullable = false)
    private Shop shop;

    public boolean isLowStock() {
        return trackInventory && currentStock != null && 
               lowStockAlert != null && currentStock <= lowStockAlert;
    }

    public void reduceStock(int quantity) {
        if (trackInventory && currentStock != null) {
            this.currentStock -= quantity;
        }
    }

    public void addStock(int quantity) {
        if (trackInventory && currentStock != null) {
            this.currentStock += quantity;
        }
    }
}
