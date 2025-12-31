package com.billingapp.controller;

import com.billingapp.dto.common.ApiResponse;
import com.billingapp.dto.dashboard.DashboardStats;
import com.billingapp.security.CurrentUser;
import com.billingapp.security.UserPrincipal;
import com.billingapp.service.DashboardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/v1/dashboard")
@RequiredArgsConstructor
@Tag(name = "Dashboard", description = "Dashboard statistics APIs")
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/stats")
    @Operation(summary = "Get dashboard statistics")
    public ResponseEntity<ApiResponse<DashboardStats>> getDashboardStats(@CurrentUser UserPrincipal currentUser) {
        DashboardStats stats = dashboardService.getDashboardStats(currentUser.getId());
        return ResponseEntity.ok(ApiResponse.success(stats));
    }
}
