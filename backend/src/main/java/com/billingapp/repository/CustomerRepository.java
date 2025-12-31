package com.billingapp.repository;

import com.billingapp.entity.Customer;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CustomerRepository extends JpaRepository<Customer, Long> {

    Page<Customer> findByShopIdAndIsActiveTrue(Long shopId, Pageable pageable);

    List<Customer> findByShopIdAndIsActiveTrue(Long shopId);

    Optional<Customer> findByIdAndShopId(Long id, Long shopId);

    @Query("SELECT c FROM Customer c WHERE c.shop.id = :shopId AND c.isActive = true " +
           "AND (LOWER(c.customerName) LIKE LOWER(CONCAT('%', :search, '%')) " +
           "OR LOWER(c.phoneNumber) LIKE LOWER(CONCAT('%', :search, '%')) " +
           "OR LOWER(c.email) LIKE LOWER(CONCAT('%', :search, '%')))")
    Page<Customer> searchCustomers(Long shopId, String search, Pageable pageable);

    long countByShopIdAndIsActiveTrue(Long shopId);
}
