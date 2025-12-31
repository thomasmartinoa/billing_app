package com.billingapp.service;

import com.billingapp.dto.common.PagedResponse;
import com.billingapp.dto.customer.CustomerRequest;
import com.billingapp.dto.customer.CustomerResponse;
import com.billingapp.entity.Customer;
import com.billingapp.entity.Shop;
import com.billingapp.exception.ResourceNotFoundException;
import com.billingapp.repository.CustomerRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class CustomerService {

    private final CustomerRepository customerRepository;
    private final ShopService shopService;

    @Transactional
    public CustomerResponse createCustomer(Long userId, CustomerRequest request) {
        Shop shop = shopService.getShopEntity(userId);

        Customer customer = Customer.builder()
                .customerName(request.getCustomerName())
                .phoneNumber(request.getPhoneNumber())
                .email(request.getEmail())
                .address(request.getAddress())
                .gstNumber(request.getGstNumber())
                .notes(request.getNotes())
                .shop(shop)
                .build();

        customer = customerRepository.save(customer);
        log.info("Customer created: {} for shop {}", customer.getCustomerName(), shop.getId());

        return mapToResponse(customer);
    }

    @Transactional(readOnly = true)
    public PagedResponse<CustomerResponse> getCustomers(Long userId, int page, int size, String search) {
        Shop shop = shopService.getShopEntity(userId);
        Pageable pageable = PageRequest.of(page, size, Sort.by("customerName").ascending());

        Page<Customer> customerPage;
        if (search != null && !search.trim().isEmpty()) {
            customerPage = customerRepository.searchCustomers(shop.getId(), search.trim(), pageable);
        } else {
            customerPage = customerRepository.findByShopIdAndIsActiveTrue(shop.getId(), pageable);
        }

        List<CustomerResponse> customers = customerPage.getContent().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());

        return PagedResponse.<CustomerResponse>builder()
                .content(customers)
                .page(customerPage.getNumber())
                .size(customerPage.getSize())
                .totalElements(customerPage.getTotalElements())
                .totalPages(customerPage.getTotalPages())
                .first(customerPage.isFirst())
                .last(customerPage.isLast())
                .build();
    }

    @Transactional(readOnly = true)
    public List<CustomerResponse> getAllCustomers(Long userId) {
        Shop shop = shopService.getShopEntity(userId);
        return customerRepository.findByShopIdAndIsActiveTrue(shop.getId()).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public CustomerResponse getCustomer(Long userId, Long customerId) {
        Shop shop = shopService.getShopEntity(userId);
        Customer customer = customerRepository.findByIdAndShopId(customerId, shop.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Customer", "id", customerId));
        return mapToResponse(customer);
    }

    @Transactional
    public CustomerResponse updateCustomer(Long userId, Long customerId, CustomerRequest request) {
        Shop shop = shopService.getShopEntity(userId);
        Customer customer = customerRepository.findByIdAndShopId(customerId, shop.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Customer", "id", customerId));

        customer.setCustomerName(request.getCustomerName());
        customer.setPhoneNumber(request.getPhoneNumber());
        customer.setEmail(request.getEmail());
        customer.setAddress(request.getAddress());
        customer.setGstNumber(request.getGstNumber());
        customer.setNotes(request.getNotes());

        customer = customerRepository.save(customer);
        log.info("Customer updated: {}", customerId);

        return mapToResponse(customer);
    }

    @Transactional
    public void deleteCustomer(Long userId, Long customerId) {
        Shop shop = shopService.getShopEntity(userId);
        Customer customer = customerRepository.findByIdAndShopId(customerId, shop.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Customer", "id", customerId));

        customer.setIsActive(false);
        customerRepository.save(customer);
        log.info("Customer soft deleted: {}", customerId);
    }

    private CustomerResponse mapToResponse(Customer customer) {
        return CustomerResponse.builder()
                .id(customer.getId())
                .customerName(customer.getCustomerName())
                .phoneNumber(customer.getPhoneNumber())
                .email(customer.getEmail())
                .address(customer.getAddress())
                .gstNumber(customer.getGstNumber())
                .notes(customer.getNotes())
                .totalPurchases(customer.getTotalPurchases())
                .totalInvoices(customer.getTotalInvoices())
                .createdAt(customer.getCreatedAt())
                .updatedAt(customer.getUpdatedAt())
                .build();
    }
}
