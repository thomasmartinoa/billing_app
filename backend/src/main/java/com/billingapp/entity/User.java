package com.billingapp.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "users", uniqueConstraints = {
        @UniqueConstraint(columnNames = "email")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User extends BaseEntity {

    @NotBlank
    @Size(max = 100)
    @Column(name = "full_name")
    private String fullName;

    @NotBlank
    @Size(max = 100)
    @Email
    @Column(unique = true)
    private String email;

    @NotBlank
    @Size(max = 255)
    private String password;

    @Column(name = "phone_number")
    private String phoneNumber;

    @Column(name = "profile_image_url")
    private String profileImageUrl;

    @Column(name = "email_verified")
    private Boolean emailVerified = false;

    @Column(name = "google_id")
    private String googleId;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private AuthProvider provider = AuthProvider.LOCAL;

    @OneToOne(mappedBy = "owner", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private Shop shop;

    @Column(name = "refresh_token")
    private String refreshToken;

    public enum AuthProvider {
        LOCAL, GOOGLE
    }
}
