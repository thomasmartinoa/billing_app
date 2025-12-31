# Billing App - Full Stack Application

A production-ready billing application with a Flutter mobile/web frontend and Spring Boot REST API backend.

## Project Structure

```
billing_app/
├── lib/                    # Flutter app source code
│   ├── core/               # Core services and configs
│   │   ├── config/         # API configuration
│   │   └── services/       # API, Auth, Storage services
│   ├── models/             # Data models
│   └── screens/            # UI screens
├── backend/                # Spring Boot API
│   └── src/main/java/com/billingapp/
│       ├── config/         # Security config
│       ├── controller/     # REST endpoints
│       ├── dto/            # Data Transfer Objects
│       ├── entity/         # JPA entities
│       ├── exception/      # Exception handling
│       ├── repository/     # Data repositories
│       ├── security/       # JWT authentication
│       └── service/        # Business logic
└── assets/                 # Flutter assets
```

## Features

### Mobile App (Flutter)
- 📱 Cross-platform (Android, iOS, Web)
- 🎨 Modern dark theme UI
- 🔐 User authentication
- 🏪 Shop setup wizard
- 👥 Customer management
- 📦 Product management with inventory
- 🧾 Invoice creation and management
- 📊 Dashboard with statistics

### Backend API (Spring Boot)
- 🔒 JWT-based authentication
- 📝 RESTful API design
- 🗄️ PostgreSQL database
- 📖 Swagger API documentation
- ✅ Input validation
- 🔄 Pagination and search

## Getting Started

### Prerequisites

- Flutter 3.x
- Java 17+
- Maven 3.8+
- PostgreSQL 15+ (for production)

### Run the Backend

```bash
cd backend

# Development mode (H2 in-memory database)
mvn spring-boot:run

# Production mode
mvn spring-boot:run -Dspring.profiles.active=prod
```

API will be available at: http://localhost:8080/api
Swagger UI: http://localhost:8080/api/swagger-ui.html

### Run the Flutter App

```bash
# Get dependencies
flutter pub get

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios

# Run on Web
flutter run -d chrome
```

### Configuration

#### Backend
Edit `backend/src/main/resources/application.yml` for:
- Database connection
- JWT secret and expiration
- Server port

#### Flutter App
Edit `lib/core/config/api_config.dart` for:
- API base URL

## API Endpoints

| Category | Endpoint | Description |
|----------|----------|-------------|
| Auth | POST /v1/auth/signup | Register |
| Auth | POST /v1/auth/login | Login |
| Shop | POST /v1/shop/setup | Setup shop |
| Customers | GET /v1/customers | List customers |
| Products | GET /v1/products | List products |
| Invoices | POST /v1/invoices | Create invoice |
| Dashboard | GET /v1/dashboard/stats | Get stats |

## Database Schema

```
users ─┬─ shops ─┬─ customers
       │         ├─ products ─── categories
       │         └─ invoices ─── invoice_items
```

## Tech Stack

### Frontend
- Flutter 3.x
- Provider (state management)
- HTTP package
- Shared Preferences

### Backend
- Spring Boot 3.2
- Spring Security
- Spring Data JPA
- PostgreSQL / H2
- JWT (jjwt)
- Lombok
- SpringDoc OpenAPI

## License

MIT License
