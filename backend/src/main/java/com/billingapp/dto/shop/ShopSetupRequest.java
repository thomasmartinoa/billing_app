package com.billingapp.dto.shop;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class ShopSetupRequest {

    @NotBlank(message = "Shop name is required")
    @Size(max = 100)
    private String shopName;

    private String shopType;
    private String tagline;
    private String address;
    private String phoneNumber;
    private String email;
    private String website;
    private String gstNumber;
    private Integer iconCode;
    private String logoUrl;

    // Business Settings
    private String currency = "INR";
    private BigDecimal taxRate = BigDecimal.valueOf(18.00);
    private String invoicePrefix = "INV";
    private Boolean includeTaxInPrice = false;
    private String termsAndConditions;
    private String footerNote;
}
