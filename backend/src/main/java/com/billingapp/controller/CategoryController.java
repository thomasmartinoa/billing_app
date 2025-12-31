package com.billingapp.controller;

import com.billingapp.dto.category.CategoryRequest;
import com.billingapp.dto.category.CategoryResponse;
import com.billingapp.dto.common.ApiResponse;
import com.billingapp.security.CurrentUser;
import com.billingapp.security.UserPrincipal;
import com.billingapp.service.CategoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/v1/categories")
@RequiredArgsConstructor
@Tag(name = "Categories", description = "Category management APIs")
public class CategoryController {

    private final CategoryService categoryService;

    @PostMapping
    @Operation(summary = "Create a new category")
    public ResponseEntity<ApiResponse<CategoryResponse>> createCategory(
            @CurrentUser UserPrincipal currentUser,
            @Valid @RequestBody CategoryRequest request) {
        CategoryResponse response = categoryService.createCategory(currentUser.getId(), request);
        return ResponseEntity.ok(ApiResponse.success("Category created", response));
    }

    @GetMapping
    @Operation(summary = "Get all categories")
    public ResponseEntity<ApiResponse<List<CategoryResponse>>> getCategories(@CurrentUser UserPrincipal currentUser) {
        List<CategoryResponse> response = categoryService.getCategories(currentUser.getId());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get category by ID")
    public ResponseEntity<ApiResponse<CategoryResponse>> getCategory(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id) {
        CategoryResponse response = categoryService.getCategory(currentUser.getId(), id);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update a category")
    public ResponseEntity<ApiResponse<CategoryResponse>> updateCategory(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id,
            @Valid @RequestBody CategoryRequest request) {
        CategoryResponse response = categoryService.updateCategory(currentUser.getId(), id, request);
        return ResponseEntity.ok(ApiResponse.success("Category updated", response));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete a category")
    public ResponseEntity<ApiResponse<Void>> deleteCategory(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id) {
        categoryService.deleteCategory(currentUser.getId(), id);
        return ResponseEntity.ok(ApiResponse.success("Category deleted", null));
    }
}
