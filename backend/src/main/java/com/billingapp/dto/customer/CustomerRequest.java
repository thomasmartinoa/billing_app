package com.billingapp.dto.customer;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CustomerRequest {

    @NotBlank(message = "Customer name is required")
    @Size(max = 100)
    private String customerName;

    private String phoneNumber;

    @Email(message = "Invalid email format")
    private String email;

    private String address;
    private String gstNumber;
    private String notes;
}
