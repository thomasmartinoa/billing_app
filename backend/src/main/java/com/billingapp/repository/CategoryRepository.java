package com.billingapp.repository;

import com.billingapp.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {

    List<Category> findByShopIdAndIsActiveTrue(Long shopId);

    Optional<Category> findByIdAndShopId(Long id, Long shopId);

    boolean existsByCategoryNameAndShopId(String categoryName, Long shopId);
}
