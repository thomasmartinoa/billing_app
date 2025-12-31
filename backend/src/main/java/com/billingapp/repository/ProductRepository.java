package com.billingapp.repository;

import com.billingapp.entity.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

    Page<Product> findByShopIdAndIsActiveTrue(Long shopId, Pageable pageable);

    List<Product> findByShopIdAndIsActiveTrue(Long shopId);

    Optional<Product> findByIdAndShopId(Long id, Long shopId);

    @Query("SELECT p FROM Product p WHERE p.shop.id = :shopId AND p.isActive = true " +
           "AND (LOWER(p.productName) LIKE LOWER(CONCAT('%', :search, '%')) " +
           "OR LOWER(p.sku) LIKE LOWER(CONCAT('%', :search, '%')) " +
           "OR LOWER(p.barcode) LIKE LOWER(CONCAT('%', :search, '%')))")
    Page<Product> searchProducts(Long shopId, String search, Pageable pageable);

    List<Product> findByCategoryIdAndIsActiveTrue(Long categoryId);

    @Query("SELECT p FROM Product p WHERE p.shop.id = :shopId AND p.isActive = true " +
           "AND p.trackInventory = true AND p.currentStock <= p.lowStockAlert")
    List<Product> findLowStockProducts(Long shopId);

    long countByShopIdAndIsActiveTrue(Long shopId);

    @Query("SELECT COUNT(p) FROM Product p WHERE p.shop.id = :shopId AND p.isActive = true " +
           "AND p.trackInventory = true AND p.currentStock <= p.lowStockAlert")
    long countLowStockProducts(Long shopId);

    Optional<Product> findBySkuAndShopId(String sku, Long shopId);

    Optional<Product> findByBarcodeAndShopId(String barcode, Long shopId);
}
