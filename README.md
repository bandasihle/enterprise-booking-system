# Enterprise Booking System (EBS)

> A Jakarta EE 10 web application for real-time venue booking and ICT lab seat allocation.

## Tech Stack

| Layer    | Technology                                      |
|----------|-------------------------------------------------|
| Backend  | Jakarta EE 10, EJB, JPA, JAX-RS, WebSockets    |
| Frontend | HTML5, CSS3, JavaScript, Fetch API              |
| Database | MySQL 8                                         |
| Server   | GlassFish 7                                     |
| Build    | Maven                                           |

## Key Features

- **Role-Based Access** â€” Students, Lecturers, and Admins each have dedicated dashboards
- **2FA Authentication** â€” Email OTP verification on every login
- **Real-Time Availability** â€” WebSocket broadcasts seat status instantly to all users
- **Deadlock Prevention** â€” JPA Optimistic Locking (`@Version`) ensures concurrent booking attempts are resolved fairly
- **No-Show Auto-Release** â€” EJB `@Schedule` timer releases unclaimed seats after 15 minutes
- **Admin Controls** â€” Ban users with excessive cancellations, manage lab capacity, review complaints

## Project Structure

```
src/main/java/com/ebs/
â”œâ”€â”€ entity/       # JPA entities (User, Booking, Lab, Seat, OtpToken...)
â”œâ”€â”€ ejb/          # Business logic, @Schedule timers (NoShow, Ban enforcement)
â”œâ”€â”€ rest/         # JAX-RS REST API endpoints
â”œâ”€â”€ websocket/    # Real-time seat update broadcaster
â”œâ”€â”€ auth/         # OTP generation & verification
â””â”€â”€ util/         # Password hashing, helpers
```

## Setup

### Prerequisites
- JDK 17+
- GlassFish 7
- MySQL 8
- Maven 3.8+

### Database
```sql
CREATE DATABASE ebs_db;
```

### GlassFish JDBC Pool
Configure a JDBC connection pool named `ebsPool` pointing to `ebs_db`, then create a resource named `jdbc/ebsDS`.

### Build & Deploy
```bash
mvn clean package
# Deploy target/ebs.war to GlassFish
```

## Architecture Highlight: Deadlock Prevention

The "Ant Mechanism" from our design is implemented using **JPA Optimistic Locking**.
The `Seat` entity carries a `@Version` field. When two users attempt to book the same seat simultaneously:
1. Both transactions read the seat and acquire an optimistic lock
2. The first to commit increments the version and succeeds
3. The second detects the version mismatch, throws `OptimisticLockException`, and the user is shown "Seat Taken"

This is the industry-standard, database-agnostic solution to concurrent resource contention.
