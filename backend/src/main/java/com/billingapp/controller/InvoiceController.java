package com.billingapp.controller;

import com.billingapp.dto.common.ApiResponse;
import com.billingapp.dto.common.PagedResponse;
import com.billingapp.dto.invoice.InvoiceRequest;
import com.billingapp.dto.invoice.InvoiceResponse;
import com.billingapp.entity.Invoice;
import com.billingapp.security.CurrentUser;
import com.billingapp.security.UserPrincipal;
import com.billingapp.service.InvoiceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

@RestController
@RequestMapping("/v1/invoices")
@RequiredArgsConstructor
@Tag(name = "Invoices", description = "Invoice management APIs")
public class InvoiceController {

    private final InvoiceService invoiceService;

    @PostMapping
    @Operation(summary = "Create a new invoice")
    public ResponseEntity<ApiResponse<InvoiceResponse>> createInvoice(
            @CurrentUser UserPrincipal currentUser,
            @Valid @RequestBody InvoiceRequest request) {
        InvoiceResponse response = invoiceService.createInvoice(currentUser.getId(), request);
        return ResponseEntity.ok(ApiResponse.success("Invoice created", response));
    }

    @GetMapping
    @Operation(summary = "Get paginated list of invoices")
    public ResponseEntity<ApiResponse<PagedResponse<InvoiceResponse>>> getInvoices(
            @CurrentUser UserPrincipal currentUser,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) Invoice.PaymentStatus status) {
        PagedResponse<InvoiceResponse> response = invoiceService.getInvoices(
                currentUser.getId(), page, size, search, status);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get invoice by ID")
    public ResponseEntity<ApiResponse<InvoiceResponse>> getInvoice(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id) {
        InvoiceResponse response = invoiceService.getInvoice(currentUser.getId(), id);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping("/{id}/mark-paid")
    @Operation(summary = "Mark invoice as paid")
    public ResponseEntity<ApiResponse<InvoiceResponse>> markAsPaid(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id,
            @RequestParam Invoice.PaymentMethod paymentMethod) {
        InvoiceResponse response = invoiceService.markAsPaid(currentUser.getId(), id, paymentMethod);
        return ResponseEntity.ok(ApiResponse.success("Invoice marked as paid", response));
    }

    @PostMapping("/{id}/payment")
    @Operation(summary = "Record a payment")
    public ResponseEntity<ApiResponse<InvoiceResponse>> recordPayment(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id,
            @RequestParam BigDecimal amount,
            @RequestParam Invoice.PaymentMethod paymentMethod) {
        InvoiceResponse response = invoiceService.recordPayment(currentUser.getId(), id, amount, paymentMethod);
        return ResponseEntity.ok(ApiResponse.success("Payment recorded", response));
    }

    @PostMapping("/{id}/cancel")
    @Operation(summary = "Cancel an invoice")
    public ResponseEntity<ApiResponse<Void>> cancelInvoice(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id) {
        invoiceService.cancelInvoice(currentUser.getId(), id);
        return ResponseEntity.ok(ApiResponse.success("Invoice cancelled", null));
    }
}
