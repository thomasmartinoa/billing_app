package com.billingapp.repository;

import com.billingapp.entity.Shop;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ShopRepository extends JpaRepository<Shop, Long> {

    Optional<Shop> findByOwnerId(Long ownerId);

    @Query("SELECT s FROM Shop s WHERE s.owner.email = :email")
    Optional<Shop> findByOwnerEmail(String email);

    boolean existsByOwnerId(Long ownerId);
}
