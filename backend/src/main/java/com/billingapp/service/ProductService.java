package com.billingapp.service;

import com.billingapp.dto.common.PagedResponse;
import com.billingapp.dto.product.ProductRequest;
import com.billingapp.dto.product.ProductResponse;
import com.billingapp.entity.Category;
import com.billingapp.entity.Product;
import com.billingapp.entity.Shop;
import com.billingapp.exception.ResourceNotFoundException;
import com.billingapp.repository.CategoryRepository;
import com.billingapp.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProductService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final ShopService shopService;

    @Transactional
    public ProductResponse createProduct(Long userId, ProductRequest request) {
        Shop shop = shopService.getShopEntity(userId);

        Category category = null;
        if (request.getCategoryId() != null) {
            category = categoryRepository.findByIdAndShopId(request.getCategoryId(), shop.getId())
                    .orElseThrow(() -> new ResourceNotFoundException("Category", "id", request.getCategoryId()));
        }

        Product product = Product.builder()
                .productName(request.getProductName())
                .description(request.getDescription())
                .sellingPrice(request.getSellingPrice())
                .costPrice(request.getCostPrice())
                .sku(request.getSku())
                .barcode(request.getBarcode())
                .unit(request.getUnit())
                .trackInventory(request.getTrackInventory())
                .currentStock(request.getCurrentStock())
                .lowStockAlert(request.getLowStockAlert())
                .imageUrl(request.getImageUrl())
                .category(category)
                .shop(shop)
                .build();

        product = productRepository.save(product);
        log.info("Product created: {} for shop {}", product.getProductName(), shop.getId());

        return mapToResponse(product);
    }

    @Transactional(readOnly = true)
    public PagedResponse<ProductResponse> getProducts(Long userId, int page, int size, String search) {
        Shop shop = shopService.getShopEntity(userId);
        Pageable pageable = PageRequest.of(page, size, Sort.by("productName").ascending());

        Page<Product> productPage;
        if (search != null && !search.trim().isEmpty()) {
            productPage = productRepository.searchProducts(shop.getId(), search.trim(), pageable);
        } else {
            productPage = productRepository.findByShopIdAndIsActiveTrue(shop.getId(), pageable);
        }

        List<ProductResponse> products = productPage.getContent().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());

        return PagedResponse.<ProductResponse>builder()
                .content(products)
                .page(productPage.getNumber())
                .size(productPage.getSize())
                .totalElements(productPage.getTotalElements())
                .totalPages(productPage.getTotalPages())
                .first(productPage.isFirst())
                .last(productPage.isLast())
                .build();
    }

    @Transactional(readOnly = true)
    public List<ProductResponse> getAllProducts(Long userId) {
        Shop shop = shopService.getShopEntity(userId);
        return productRepository.findByShopIdAndIsActiveTrue(shop.getId()).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public ProductResponse getProduct(Long userId, Long productId) {
        Shop shop = shopService.getShopEntity(userId);
        Product product = productRepository.findByIdAndShopId(productId, shop.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Product", "id", productId));
        return mapToResponse(product);
    }

    @Transactional(readOnly = true)
    public List<ProductResponse> getLowStockProducts(Long userId) {
        Shop shop = shopService.getShopEntity(userId);
        return productRepository.findLowStockProducts(shop.getId()).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public ProductResponse updateProduct(Long userId, Long productId, ProductRequest request) {
        Shop shop = shopService.getShopEntity(userId);
        Product product = productRepository.findByIdAndShopId(productId, shop.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Product", "id", productId));

        Category category = null;
        if (request.getCategoryId() != null) {
            category = categoryRepository.findByIdAndShopId(request.getCategoryId(), shop.getId())
                    .orElseThrow(() -> new ResourceNotFoundException("Category", "id", request.getCategoryId()));
        }

        product.setProductName(request.getProductName());
        product.setDescription(request.getDescription());
        product.setSellingPrice(request.getSellingPrice());
        product.setCostPrice(request.getCostPrice());
        product.setSku(request.getSku());
        product.setBarcode(request.getBarcode());
        product.setUnit(request.getUnit());
        product.setTrackInventory(request.getTrackInventory());
        product.setCurrentStock(request.getCurrentStock());
        product.setLowStockAlert(request.getLowStockAlert());
        product.setImageUrl(request.getImageUrl());
        product.setCategory(category);

        product = productRepository.save(product);
        log.info("Product updated: {}", productId);

        return mapToResponse(product);
    }

    @Transactional
    public ProductResponse updateStock(Long userId, Long productId, int quantity) {
        Shop shop = shopService.getShopEntity(userId);
        Product product = productRepository.findByIdAndShopId(productId, shop.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Product", "id", productId));

        product.setCurrentStock(quantity);
        product = productRepository.save(product);
        log.info("Product stock updated: {} -> {}", productId, quantity);

        return mapToResponse(product);
    }

    @Transactional
    public void deleteProduct(Long userId, Long productId) {
        Shop shop = shopService.getShopEntity(userId);
        Product product = productRepository.findByIdAndShopId(productId, shop.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Product", "id", productId));

        product.setIsActive(false);
        productRepository.save(product);
        log.info("Product soft deleted: {}", productId);
    }

    private ProductResponse mapToResponse(Product product) {
        return ProductResponse.builder()
                .id(product.getId())
                .productName(product.getProductName())
                .description(product.getDescription())
                .sellingPrice(product.getSellingPrice())
                .costPrice(product.getCostPrice())
                .sku(product.getSku())
                .barcode(product.getBarcode())
                .unit(product.getUnit())
                .trackInventory(product.getTrackInventory())
                .currentStock(product.getCurrentStock())
                .lowStockAlert(product.getLowStockAlert())
                .isLowStock(product.isLowStock())
                .imageUrl(product.getImageUrl())
                .categoryId(product.getCategory() != null ? product.getCategory().getId() : null)
                .categoryName(product.getCategory() != null ? product.getCategory().getCategoryName() : null)
                .createdAt(product.getCreatedAt())
                .updatedAt(product.getUpdatedAt())
                .build();
    }
}
