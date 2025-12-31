package com.billingapp.repository;

import com.billingapp.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    Boolean existsByEmail(String email);

    Optional<User> findByGoogleId(String googleId);

    @Query("SELECT u FROM User u LEFT JOIN FETCH u.shop WHERE u.email = :email")
    Optional<User> findByEmailWithShop(String email);
}
