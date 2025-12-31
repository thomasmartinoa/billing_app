package com.billingapp.service;

import com.billingapp.dto.common.PagedResponse;
import com.billingapp.dto.invoice.InvoiceRequest;
import com.billingapp.dto.invoice.InvoiceResponse;
import com.billingapp.entity.*;
import com.billingapp.exception.BadRequestException;
import com.billingapp.exception.ResourceNotFoundException;
import com.billingapp.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class InvoiceService {

    private final InvoiceRepository invoiceRepository;
    private final CustomerRepository customerRepository;
    private final ProductRepository productRepository;
    private final ShopRepository shopRepository;
    private final ShopService shopService;

    @Transactional
    public InvoiceResponse createInvoice(Long userId, InvoiceRequest request) {
        Shop shop = shopService.getShopEntity(userId);

        Customer customer = null;
        if (request.getCustomerId() != null) {
            customer = customerRepository.findByIdAndShopId(request.getCustomerId(), shop.getId())
                    .orElseThrow(() -> new ResourceNotFoundException("Customer", "id", request.getCustomerId()));
        }

        Invoice invoice = Invoice.builder()
                .invoiceNumber(shop.generateInvoiceNumber())
                .invoiceDate(request.getInvoiceDate())
                .dueDate(request.getDueDate())
                .discountAmount(request.getDiscountAmount())
                .discountPercentage(request.getDiscountPercentage())
                .taxRate(shop.getTaxRate())
                .paymentMethod(request.getPaymentMethod())
                .notes(request.getNotes())
                .customer(customer)
                .shop(shop)
                .build();

        // Add items
        for (InvoiceRequest.InvoiceItemRequest itemRequest : request.getItems()) {
            Product product = productRepository.findByIdAndShopId(itemRequest.getProductId(), shop.getId())
                    .orElseThrow(() -> new ResourceNotFoundException("Product", "id", itemRequest.getProductId()));

            BigDecimal unitPrice = itemRequest.getUnitPrice() != null 
                    ? itemRequest.getUnitPrice() 
                    : product.getSellingPrice();

            InvoiceItem item = InvoiceItem.builder()
                    .product(product)
                    .productName(product.getProductName())
                    .description(product.getDescription())
                    .quantity(itemRequest.getQuantity())
                    .unit(product.getUnit())
                    .unitPrice(unitPrice)
                    .discountAmount(itemRequest.getDiscountAmount())
                    .build();

            invoice.addItem(item);

            // Reduce stock
            if (product.getTrackInventory()) {
                product.reduceStock(itemRequest.getQuantity());
                productRepository.save(product);
            }
        }

        // Calculate totals
        invoice.calculateTotals();

        // Set payment status
        if (Boolean.TRUE.equals(request.getMarkAsPaid())) {
            invoice.setPaymentStatus(Invoice.PaymentStatus.PAID);
            invoice.setPaidAmount(invoice.getTotalAmount());
        } else {
            invoice.setPaymentStatus(Invoice.PaymentStatus.PENDING);
        }

        invoice = invoiceRepository.save(invoice);
        shopRepository.save(shop); // Save updated invoice number

        // Update customer stats
        if (customer != null) {
            customer.setTotalInvoices(customer.getTotalInvoices() + 1);
            customer.setTotalPurchases(customer.getTotalPurchases().add(invoice.getTotalAmount()));
            customerRepository.save(customer);
        }

        log.info("Invoice created: {} for shop {}", invoice.getInvoiceNumber(), shop.getId());

        return mapToResponse(invoice);
    }

    @Transactional(readOnly = true)
    public PagedResponse<InvoiceResponse> getInvoices(Long userId, int page, int size, 
                                                       String search, Invoice.PaymentStatus status) {
        Shop shop = shopService.getShopEntity(userId);
        Pageable pageable = PageRequest.of(page, size, Sort.by("invoiceDate").descending());

        Page<Invoice> invoicePage;
        if (search != null && !search.trim().isEmpty()) {
            invoicePage = invoiceRepository.searchInvoices(shop.getId(), search.trim(), pageable);
        } else if (status != null) {
            invoicePage = invoiceRepository.findByShopIdAndPaymentStatusAndIsActiveTrue(shop.getId(), status, pageable);
        } else {
            invoicePage = invoiceRepository.findByShopIdAndIsActiveTrue(shop.getId(), pageable);
        }

        List<InvoiceResponse> invoices = invoicePage.getContent().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());

        return PagedResponse.<InvoiceResponse>builder()
                .content(invoices)
                .page(invoicePage.getNumber())
                .size(invoicePage.getSize())
                .totalElements(invoicePage.getTotalElements())
                .totalPages(invoicePage.getTotalPages())
                .first(invoicePage.isFirst())
                .last(invoicePage.isLast())
                .build();
    }

    @Transactional(readOnly = true)
    public InvoiceResponse getInvoice(Long userId, Long invoiceId) {
        Shop shop = shopService.getShopEntity(userId);
        Invoice invoice = invoiceRepository.findByIdWithItems(invoiceId, shop.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Invoice", "id", invoiceId));
        return mapToResponse(invoice);
    }

    @Transactional
    public InvoiceResponse markAsPaid(Long userId, Long invoiceId, Invoice.PaymentMethod paymentMethod) {
        Shop shop = shopService.getShopEntity(userId);
        Invoice invoice = invoiceRepository.findByIdAndShopId(invoiceId, shop.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Invoice", "id", invoiceId));

        if (invoice.getPaymentStatus() == Invoice.PaymentStatus.PAID) {
            throw new BadRequestException("Invoice is already paid");
        }

        invoice.setPaymentStatus(Invoice.PaymentStatus.PAID);
        invoice.setPaidAmount(invoice.getTotalAmount());
        invoice.setPaymentMethod(paymentMethod);

        invoice = invoiceRepository.save(invoice);
        log.info("Invoice marked as paid: {}", invoiceId);

        return mapToResponse(invoice);
    }

    @Transactional
    public InvoiceResponse recordPayment(Long userId, Long invoiceId, BigDecimal amount, 
                                         Invoice.PaymentMethod paymentMethod) {
        Shop shop = shopService.getShopEntity(userId);
        Invoice invoice = invoiceRepository.findByIdAndShopId(invoiceId, shop.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Invoice", "id", invoiceId));

        BigDecimal newPaidAmount = invoice.getPaidAmount().add(amount);
        invoice.setPaidAmount(newPaidAmount);
        invoice.setPaymentMethod(paymentMethod);

        if (newPaidAmount.compareTo(invoice.getTotalAmount()) >= 0) {
            invoice.setPaymentStatus(Invoice.PaymentStatus.PAID);
        } else {
            invoice.setPaymentStatus(Invoice.PaymentStatus.PARTIAL);
        }

        invoice = invoiceRepository.save(invoice);
        log.info("Payment recorded for invoice {}: {}", invoiceId, amount);

        return mapToResponse(invoice);
    }

    @Transactional
    public void cancelInvoice(Long userId, Long invoiceId) {
        Shop shop = shopService.getShopEntity(userId);
        Invoice invoice = invoiceRepository.findByIdWithItems(invoiceId, shop.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Invoice", "id", invoiceId));

        // Restore stock
        for (InvoiceItem item : invoice.getItems()) {
            if (item.getProduct() != null && item.getProduct().getTrackInventory()) {
                item.getProduct().addStock(item.getQuantity());
                productRepository.save(item.getProduct());
            }
        }

        invoice.setPaymentStatus(Invoice.PaymentStatus.CANCELLED);
        invoice.setIsActive(false);
        invoiceRepository.save(invoice);

        log.info("Invoice cancelled: {}", invoiceId);
    }

    private InvoiceResponse mapToResponse(Invoice invoice) {
        InvoiceResponse.CustomerInfo customerInfo = null;
        if (invoice.getCustomer() != null) {
            Customer c = invoice.getCustomer();
            customerInfo = InvoiceResponse.CustomerInfo.builder()
                    .id(c.getId())
                    .customerName(c.getCustomerName())
                    .phoneNumber(c.getPhoneNumber())
                    .email(c.getEmail())
                    .address(c.getAddress())
                    .gstNumber(c.getGstNumber())
                    .build();
        }

        List<InvoiceResponse.InvoiceItemResponse> items = invoice.getItems().stream()
                .map(item -> InvoiceResponse.InvoiceItemResponse.builder()
                        .id(item.getId())
                        .productId(item.getProduct() != null ? item.getProduct().getId() : null)
                        .productName(item.getProductName())
                        .description(item.getDescription())
                        .quantity(item.getQuantity())
                        .unit(item.getUnit())
                        .unitPrice(item.getUnitPrice())
                        .discountAmount(item.getDiscountAmount())
                        .lineTotal(item.getLineTotal())
                        .build())
                .collect(Collectors.toList());

        return InvoiceResponse.builder()
                .id(invoice.getId())
                .invoiceNumber(invoice.getInvoiceNumber())
                .invoiceDate(invoice.getInvoiceDate())
                .dueDate(invoice.getDueDate())
                .customer(customerInfo)
                .items(items)
                .subtotal(invoice.getSubtotal())
                .discountAmount(invoice.getDiscountAmount())
                .discountPercentage(invoice.getDiscountPercentage())
                .taxRate(invoice.getTaxRate())
                .taxAmount(invoice.getTaxAmount())
                .totalAmount(invoice.getTotalAmount())
                .paidAmount(invoice.getPaidAmount())
                .balanceDue(invoice.getBalanceDue())
                .paymentStatus(invoice.getPaymentStatus())
                .paymentMethod(invoice.getPaymentMethod())
                .notes(invoice.getNotes())
                .createdAt(invoice.getCreatedAt())
                .updatedAt(invoice.getUpdatedAt())
                .build();
    }
}
