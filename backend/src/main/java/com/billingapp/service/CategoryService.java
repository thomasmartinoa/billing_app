package com.billingapp.service;

import com.billingapp.dto.category.CategoryRequest;
import com.billingapp.dto.category.CategoryResponse;
import com.billingapp.entity.Category;
import com.billingapp.entity.Shop;
import com.billingapp.exception.BadRequestException;
import com.billingapp.exception.ResourceNotFoundException;
import com.billingapp.repository.CategoryRepository;
import com.billingapp.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class CategoryService {

    private final CategoryRepository categoryRepository;
    private final ProductRepository productRepository;
    private final ShopService shopService;

    @Transactional
    public CategoryResponse createCategory(Long userId, CategoryRequest request) {
        Shop shop = shopService.getShopEntity(userId);

        if (categoryRepository.existsByCategoryNameAndShopId(request.getCategoryName(), shop.getId())) {
            throw new BadRequestException("Category with this name already exists");
        }

        Category category = Category.builder()
                .categoryName(request.getCategoryName())
                .description(request.getDescription())
                .colorCode(request.getColorCode())
                .shop(shop)
                .build();

        category = categoryRepository.save(category);
        log.info("Category created: {} for shop {}", category.getCategoryName(), shop.getId());

        return mapToResponse(category);
    }

    @Transactional(readOnly = true)
    public List<CategoryResponse> getCategories(Long userId) {
        Shop shop = shopService.getShopEntity(userId);
        return categoryRepository.findByShopIdAndIsActiveTrue(shop.getId()).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public CategoryResponse getCategory(Long userId, Long categoryId) {
        Shop shop = shopService.getShopEntity(userId);
        Category category = categoryRepository.findByIdAndShopId(categoryId, shop.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Category", "id", categoryId));
        return mapToResponse(category);
    }

    @Transactional
    public CategoryResponse updateCategory(Long userId, Long categoryId, CategoryRequest request) {
        Shop shop = shopService.getShopEntity(userId);
        Category category = categoryRepository.findByIdAndShopId(categoryId, shop.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Category", "id", categoryId));

        category.setCategoryName(request.getCategoryName());
        category.setDescription(request.getDescription());
        category.setColorCode(request.getColorCode());

        category = categoryRepository.save(category);
        log.info("Category updated: {}", categoryId);

        return mapToResponse(category);
    }

    @Transactional
    public void deleteCategory(Long userId, Long categoryId) {
        Shop shop = shopService.getShopEntity(userId);
        Category category = categoryRepository.findByIdAndShopId(categoryId, shop.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Category", "id", categoryId));

        category.setIsActive(false);
        categoryRepository.save(category);
        log.info("Category soft deleted: {}", categoryId);
    }

    private CategoryResponse mapToResponse(Category category) {
        int productCount = productRepository.findByCategoryIdAndIsActiveTrue(category.getId()).size();
        
        return CategoryResponse.builder()
                .id(category.getId())
                .categoryName(category.getCategoryName())
                .description(category.getDescription())
                .colorCode(category.getColorCode())
                .productCount(productCount)
                .build();
    }
}
