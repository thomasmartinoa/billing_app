# Billing App - Spring Boot Backend API

A production-ready REST API for the Billing Application built with Spring Boot 3.2.

## Tech Stack

- **Java 17**
- **Spring Boot 3.2.1**
- **Spring Security with JWT**
- **Spring Data JPA**
- **PostgreSQL** (Production) / **H2** (Development)
- **Lombok**
- **SpringDoc OpenAPI (Swagger)**

## Features

- ✅ User Authentication (Signup, Login, JWT Refresh)
- ✅ Shop Setup and Management
- ✅ Customer Management (CRUD)
- ✅ Product Management (CRUD with Inventory)
- ✅ Category Management
- ✅ Invoice Management (Create, Pay, Cancel)
- ✅ Dashboard Statistics
- ✅ Search and Pagination
- ✅ Global Exception Handling
- ✅ API Documentation (Swagger UI)

## Getting Started

### Prerequisites

- Java 17 or higher
- Maven 3.8+
- PostgreSQL 15+ (for production)

### Running in Development Mode

```bash
cd backend
./mvnw spring-boot:run
```

The API will start on `http://localhost:8080/api`

### Running in Production Mode

1. Set up PostgreSQL database:
```sql
CREATE DATABASE billing_db;
```

2. Configure environment variables or update `application.yml`:
```yaml
spring:
  profiles:
    active: prod
  datasource:
    url: jdbc:postgresql://localhost:5432/billing_db
    username: your_username
    password: your_password
```

3. Build and run:
```bash
./mvnw clean package -DskipTests
java -jar target/billing-api-1.0.0.jar --spring.profiles.active=prod
```

## API Documentation

When running, access Swagger UI at:
- http://localhost:8080/api/swagger-ui.html

## API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/signup` | Register new user |
| POST | `/api/v1/auth/login` | Login |
| POST | `/api/v1/auth/refresh` | Refresh token |
| POST | `/api/v1/auth/logout` | Logout |

### Shop
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/shop/setup` | Setup shop |
| GET | `/api/v1/shop` | Get shop details |
| PUT | `/api/v1/shop` | Update shop |

### Customers
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/customers` | Create customer |
| GET | `/api/v1/customers` | Get customers (paginated) |
| GET | `/api/v1/customers/all` | Get all customers |
| GET | `/api/v1/customers/{id}` | Get customer by ID |
| PUT | `/api/v1/customers/{id}` | Update customer |
| DELETE | `/api/v1/customers/{id}` | Delete customer |

### Products
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/products` | Create product |
| GET | `/api/v1/products` | Get products (paginated) |
| GET | `/api/v1/products/all` | Get all products |
| GET | `/api/v1/products/low-stock` | Get low stock products |
| GET | `/api/v1/products/{id}` | Get product by ID |
| PUT | `/api/v1/products/{id}` | Update product |
| PATCH | `/api/v1/products/{id}/stock` | Update stock |
| DELETE | `/api/v1/products/{id}` | Delete product |

### Categories
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/categories` | Create category |
| GET | `/api/v1/categories` | Get all categories |
| GET | `/api/v1/categories/{id}` | Get category by ID |
| PUT | `/api/v1/categories/{id}` | Update category |
| DELETE | `/api/v1/categories/{id}` | Delete category |

### Invoices
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/invoices` | Create invoice |
| GET | `/api/v1/invoices` | Get invoices (paginated) |
| GET | `/api/v1/invoices/{id}` | Get invoice by ID |
| POST | `/api/v1/invoices/{id}/mark-paid` | Mark as paid |
| POST | `/api/v1/invoices/{id}/payment` | Record payment |
| POST | `/api/v1/invoices/{id}/cancel` | Cancel invoice |

### Dashboard
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/dashboard/stats` | Get dashboard statistics |

## Project Structure

```
backend/
├── src/main/java/com/billingapp/
│   ├── BillingApiApplication.java
│   ├── config/
│   │   └── SecurityConfig.java
│   ├── controller/
│   │   ├── AuthController.java
│   │   ├── ShopController.java
│   │   ├── CustomerController.java
│   │   ├── ProductController.java
│   │   ├── CategoryController.java
│   │   ├── InvoiceController.java
│   │   └── DashboardController.java
│   ├── dto/
│   │   ├── auth/
│   │   ├── shop/
│   │   ├── customer/
│   │   ├── product/
│   │   ├── category/
│   │   ├── invoice/
│   │   ├── dashboard/
│   │   └── common/
│   ├── entity/
│   │   ├── BaseEntity.java
│   │   ├── User.java
│   │   ├── Shop.java
│   │   ├── Customer.java
│   │   ├── Product.java
│   │   ├── Category.java
│   │   ├── Invoice.java
│   │   └── InvoiceItem.java
│   ├── exception/
│   │   ├── BadRequestException.java
│   │   ├── ResourceNotFoundException.java
│   │   ├── ResourceAlreadyExistsException.java
│   │   └── GlobalExceptionHandler.java
│   ├── repository/
│   ├── security/
│   │   ├── CurrentUser.java
│   │   ├── UserPrincipal.java
│   │   ├── JwtTokenProvider.java
│   │   ├── JwtAuthenticationFilter.java
│   │   ├── JwtAuthenticationEntryPoint.java
│   │   └── CustomUserDetailsService.java
│   └── service/
│       ├── AuthService.java
│       ├── ShopService.java
│       ├── CustomerService.java
│       ├── ProductService.java
│       ├── CategoryService.java
│       ├── InvoiceService.java
│       └── DashboardService.java
└── src/main/resources/
    └── application.yml
```

## Security

- JWT-based authentication
- Password hashing with BCrypt
- CORS configured for mobile app
- Stateless session management

## Environment Variables (Production)

| Variable | Description | Default |
|----------|-------------|---------|
| `SPRING_PROFILES_ACTIVE` | Active profile | `dev` |
| `DATABASE_URL` | PostgreSQL URL | - |
| `DATABASE_USERNAME` | Database user | `postgres` |
| `DATABASE_PASSWORD` | Database password | - |
| `JWT_SECRET` | JWT signing key | - |
| `JWT_EXPIRATION` | Token expiry (ms) | `86400000` |

## License

MIT License
