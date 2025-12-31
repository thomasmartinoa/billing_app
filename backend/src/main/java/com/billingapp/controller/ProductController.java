package com.billingapp.controller;

import com.billingapp.dto.common.ApiResponse;
import com.billingapp.dto.common.PagedResponse;
import com.billingapp.dto.product.ProductRequest;
import com.billingapp.dto.product.ProductResponse;
import com.billingapp.security.CurrentUser;
import com.billingapp.security.UserPrincipal;
import com.billingapp.service.ProductService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/v1/products")
@RequiredArgsConstructor
@Tag(name = "Products", description = "Product management APIs")
public class ProductController {

    private final ProductService productService;

    @PostMapping
    @Operation(summary = "Create a new product")
    public ResponseEntity<ApiResponse<ProductResponse>> createProduct(
            @CurrentUser UserPrincipal currentUser,
            @Valid @RequestBody ProductRequest request) {
        ProductResponse response = productService.createProduct(currentUser.getId(), request);
        return ResponseEntity.ok(ApiResponse.success("Product created", response));
    }

    @GetMapping
    @Operation(summary = "Get paginated list of products")
    public ResponseEntity<ApiResponse<PagedResponse<ProductResponse>>> getProducts(
            @CurrentUser UserPrincipal currentUser,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String search) {
        PagedResponse<ProductResponse> response = productService.getProducts(currentUser.getId(), page, size, search);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/all")
    @Operation(summary = "Get all products (for invoice creation)")
    public ResponseEntity<ApiResponse<List<ProductResponse>>> getAllProducts(@CurrentUser UserPrincipal currentUser) {
        List<ProductResponse> response = productService.getAllProducts(currentUser.getId());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/low-stock")
    @Operation(summary = "Get low stock products")
    public ResponseEntity<ApiResponse<List<ProductResponse>>> getLowStockProducts(@CurrentUser UserPrincipal currentUser) {
        List<ProductResponse> response = productService.getLowStockProducts(currentUser.getId());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get product by ID")
    public ResponseEntity<ApiResponse<ProductResponse>> getProduct(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id) {
        ProductResponse response = productService.getProduct(currentUser.getId(), id);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update a product")
    public ResponseEntity<ApiResponse<ProductResponse>> updateProduct(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id,
            @Valid @RequestBody ProductRequest request) {
        ProductResponse response = productService.updateProduct(currentUser.getId(), id, request);
        return ResponseEntity.ok(ApiResponse.success("Product updated", response));
    }

    @PatchMapping("/{id}/stock")
    @Operation(summary = "Update product stock")
    public ResponseEntity<ApiResponse<ProductResponse>> updateStock(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id,
            @RequestParam int quantity) {
        ProductResponse response = productService.updateStock(currentUser.getId(), id, quantity);
        return ResponseEntity.ok(ApiResponse.success("Stock updated", response));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete a product")
    public ResponseEntity<ApiResponse<Void>> deleteProduct(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id) {
        productService.deleteProduct(currentUser.getId(), id);
        return ResponseEntity.ok(ApiResponse.success("Product deleted", null));
    }
}
