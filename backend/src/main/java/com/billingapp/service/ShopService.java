package com.billingapp.service;

import com.billingapp.dto.shop.ShopResponse;
import com.billingapp.dto.shop.ShopSetupRequest;
import com.billingapp.entity.Shop;
import com.billingapp.entity.User;
import com.billingapp.exception.BadRequestException;
import com.billingapp.exception.ResourceNotFoundException;
import com.billingapp.repository.ShopRepository;
import com.billingapp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class ShopService {

    private final ShopRepository shopRepository;
    private final UserRepository userRepository;

    @Transactional
    public ShopResponse setupShop(Long userId, ShopSetupRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        if (shopRepository.existsByOwnerId(userId)) {
            throw new BadRequestException("Shop already exists for this user");
        }

        Shop shop = Shop.builder()
                .shopName(request.getShopName())
                .shopType(request.getShopType())
                .tagline(request.getTagline())
                .address(request.getAddress())
                .phoneNumber(request.getPhoneNumber())
                .email(request.getEmail())
                .website(request.getWebsite())
                .gstNumber(request.getGstNumber())
                .iconCode(request.getIconCode())
                .logoUrl(request.getLogoUrl())
                .currency(request.getCurrency())
                .taxRate(request.getTaxRate())
                .invoicePrefix(request.getInvoicePrefix())
                .includeTaxInPrice(request.getIncludeTaxInPrice())
                .termsAndConditions(request.getTermsAndConditions())
                .footerNote(request.getFooterNote())
                .owner(user)
                .build();

        shop = shopRepository.save(shop);
        log.info("Shop created for user {}: {}", userId, shop.getShopName());

        return mapToResponse(shop);
    }

    @Transactional(readOnly = true)
    public ShopResponse getShop(Long userId) {
        Shop shop = shopRepository.findByOwnerId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Shop", "ownerId", userId));
        return mapToResponse(shop);
    }

    @Transactional(readOnly = true)
    public Shop getShopEntity(Long userId) {
        return shopRepository.findByOwnerId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Shop", "ownerId", userId));
    }

    @Transactional
    public ShopResponse updateShop(Long userId, ShopSetupRequest request) {
        Shop shop = shopRepository.findByOwnerId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Shop", "ownerId", userId));

        shop.setShopName(request.getShopName());
        shop.setShopType(request.getShopType());
        shop.setTagline(request.getTagline());
        shop.setAddress(request.getAddress());
        shop.setPhoneNumber(request.getPhoneNumber());
        shop.setEmail(request.getEmail());
        shop.setWebsite(request.getWebsite());
        shop.setGstNumber(request.getGstNumber());
        shop.setIconCode(request.getIconCode());
        shop.setLogoUrl(request.getLogoUrl());
        shop.setCurrency(request.getCurrency());
        shop.setTaxRate(request.getTaxRate());
        shop.setInvoicePrefix(request.getInvoicePrefix());
        shop.setIncludeTaxInPrice(request.getIncludeTaxInPrice());
        shop.setTermsAndConditions(request.getTermsAndConditions());
        shop.setFooterNote(request.getFooterNote());

        shop = shopRepository.save(shop);
        log.info("Shop updated for user {}", userId);

        return mapToResponse(shop);
    }

    private ShopResponse mapToResponse(Shop shop) {
        return ShopResponse.builder()
                .id(shop.getId())
                .shopName(shop.getShopName())
                .shopType(shop.getShopType())
                .tagline(shop.getTagline())
                .address(shop.getAddress())
                .phoneNumber(shop.getPhoneNumber())
                .email(shop.getEmail())
                .website(shop.getWebsite())
                .gstNumber(shop.getGstNumber())
                .iconCode(shop.getIconCode())
                .logoUrl(shop.getLogoUrl())
                .currency(shop.getCurrency())
                .taxRate(shop.getTaxRate())
                .invoicePrefix(shop.getInvoicePrefix())
                .includeTaxInPrice(shop.getIncludeTaxInPrice())
                .termsAndConditions(shop.getTermsAndConditions())
                .footerNote(shop.getFooterNote())
                .build();
    }
}
