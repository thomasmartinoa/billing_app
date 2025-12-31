package com.billingapp.controller;

import com.billingapp.dto.common.ApiResponse;
import com.billingapp.dto.shop.ShopResponse;
import com.billingapp.dto.shop.ShopSetupRequest;
import com.billingapp.security.CurrentUser;
import com.billingapp.security.UserPrincipal;
import com.billingapp.service.ShopService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/shop")
@RequiredArgsConstructor
@Tag(name = "Shop", description = "Shop setup and management APIs")
public class ShopController {

    private final ShopService shopService;

    @PostMapping("/setup")
    @Operation(summary = "Setup a new shop")
    public ResponseEntity<ApiResponse<ShopResponse>> setupShop(
            @CurrentUser UserPrincipal currentUser,
            @Valid @RequestBody ShopSetupRequest request) {
        ShopResponse response = shopService.setupShop(currentUser.getId(), request);
        return ResponseEntity.ok(ApiResponse.success("Shop setup successful", response));
    }

    @GetMapping
    @Operation(summary = "Get shop details")
    public ResponseEntity<ApiResponse<ShopResponse>> getShop(@CurrentUser UserPrincipal currentUser) {
        ShopResponse response = shopService.getShop(currentUser.getId());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PutMapping
    @Operation(summary = "Update shop details")
    public ResponseEntity<ApiResponse<ShopResponse>> updateShop(
            @CurrentUser UserPrincipal currentUser,
            @Valid @RequestBody ShopSetupRequest request) {
        ShopResponse response = shopService.updateShop(currentUser.getId(), request);
        return ResponseEntity.ok(ApiResponse.success("Shop updated", response));
    }
}
