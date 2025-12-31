package com.billingapp.dto.shop;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ShopResponse {

    private Long id;
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
    private String currency;
    private BigDecimal taxRate;
    private String invoicePrefix;
    private Boolean includeTaxInPrice;
    private String termsAndConditions;
    private String footerNote;
}
