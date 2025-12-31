package com.billingapp.controller;

import com.billingapp.dto.common.ApiResponse;
import com.billingapp.dto.common.PagedResponse;
import com.billingapp.dto.customer.CustomerRequest;
import com.billingapp.dto.customer.CustomerResponse;
import com.billingapp.security.CurrentUser;
import com.billingapp.security.UserPrincipal;
import com.billingapp.service.CustomerService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/v1/customers")
@RequiredArgsConstructor
@Tag(name = "Customers", description = "Customer management APIs")
public class CustomerController {

    private final CustomerService customerService;

    @PostMapping
    @Operation(summary = "Create a new customer")
    public ResponseEntity<ApiResponse<CustomerResponse>> createCustomer(
            @CurrentUser UserPrincipal currentUser,
            @Valid @RequestBody CustomerRequest request) {
        CustomerResponse response = customerService.createCustomer(currentUser.getId(), request);
        return ResponseEntity.ok(ApiResponse.success("Customer created", response));
    }

    @GetMapping
    @Operation(summary = "Get paginated list of customers")
    public ResponseEntity<ApiResponse<PagedResponse<CustomerResponse>>> getCustomers(
            @CurrentUser UserPrincipal currentUser,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String search) {
        PagedResponse<CustomerResponse> response = customerService.getCustomers(currentUser.getId(), page, size, search);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/all")
    @Operation(summary = "Get all customers (for dropdowns)")
    public ResponseEntity<ApiResponse<List<CustomerResponse>>> getAllCustomers(@CurrentUser UserPrincipal currentUser) {
        List<CustomerResponse> response = customerService.getAllCustomers(currentUser.getId());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get customer by ID")
    public ResponseEntity<ApiResponse<CustomerResponse>> getCustomer(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id) {
        CustomerResponse response = customerService.getCustomer(currentUser.getId(), id);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update a customer")
    public ResponseEntity<ApiResponse<CustomerResponse>> updateCustomer(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id,
            @Valid @RequestBody CustomerRequest request) {
        CustomerResponse response = customerService.updateCustomer(currentUser.getId(), id, request);
        return ResponseEntity.ok(ApiResponse.success("Customer updated", response));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete a customer")
    public ResponseEntity<ApiResponse<Void>> deleteCustomer(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id) {
        customerService.deleteCustomer(currentUser.getId(), id);
        return ResponseEntity.ok(ApiResponse.success("Customer deleted", null));
    }
}
