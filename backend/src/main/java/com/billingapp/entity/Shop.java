package com.billingapp.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "shops")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Shop extends BaseEntity {

    @NotBlank
    @Size(max = 100)
    @Column(name = "shop_name")
    private String shopName;

    @Column(name = "shop_type")
    private String shopType;

    @Column(name = "tagline")
    private String tagline;

    @Column(name = "address", columnDefinition = "TEXT")
    private String address;

    @Column(name = "phone_number")
    private String phoneNumber;

    @Column(name = "email")
    private String email;

    @Column(name = "website")
    private String website;

    @Column(name = "gst_number")
    private String gstNumber;

    @Column(name = "icon_code")
    private Integer iconCode;

    @Column(name = "logo_url")
    private String logoUrl;

    // Business Settings
    @Column(name = "currency", length = 10)
    private String currency = "INR";

    @Column(name = "tax_rate", precision = 5, scale = 2)
    private BigDecimal taxRate = BigDecimal.valueOf(18.00);

    @Column(name = "invoice_prefix", length = 20)
    private String invoicePrefix = "INV";

    @Column(name = "next_invoice_number")
    private Long nextInvoiceNumber = 1L;

    @Column(name = "include_tax_in_price")
    private Boolean includeTaxInPrice = false;

    @Column(name = "terms_and_conditions", columnDefinition = "TEXT")
    private String termsAndConditions;

    @Column(name = "footer_note", columnDefinition = "TEXT")
    private String footerNote;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    @OneToMany(mappedBy = "shop", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Customer> customers = new ArrayList<>();

    @OneToMany(mappedBy = "shop", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Product> products = new ArrayList<>();

    @OneToMany(mappedBy = "shop", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Invoice> invoices = new ArrayList<>();

    @OneToMany(mappedBy = "shop", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Category> categories = new ArrayList<>();

    public String generateInvoiceNumber() {
        String invoiceNumber = String.format("%s-%05d", invoicePrefix, nextInvoiceNumber);
        nextInvoiceNumber++;
        return invoiceNumber;
    }
}
