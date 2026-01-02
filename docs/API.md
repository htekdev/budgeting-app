# BudgetBuddy API Documentation

## Base URL

- Local Development: `http://localhost:5000/api`
- Production: `https://your-app.azurewebsites.net/api`

## Authentication

Currently, the API does not require authentication. Future versions will implement JWT-based authentication.

## Endpoints

### Budgets

#### GET /api/budgets

Get all budgets, optionally filtered by user.

**Query Parameters:**
- `userId` (optional): Filter budgets by user ID

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "name": "Monthly Budget - January 2026",
    "totalAmount": 5000.00,
    "startDate": "2026-01-01T00:00:00Z",
    "endDate": "2026-01-31T00:00:00Z",
    "userId": "demo-user",
    "createdAt": "2026-01-01T00:00:00Z",
    "updatedAt": "2026-01-01T00:00:00Z"
  }
]
```

**Example:**
```bash
curl http://localhost:5000/api/budgets?userId=demo-user
```

---

#### GET /api/budgets/{id}

Get a specific budget by ID.

**Path Parameters:**
- `id` (required): Budget ID

**Response:** `200 OK`
```json
{
  "id": 1,
  "name": "Monthly Budget - January 2026",
  "totalAmount": 5000.00,
  "startDate": "2026-01-01T00:00:00Z",
  "endDate": "2026-01-31T00:00:00Z",
  "userId": "demo-user",
  "createdAt": "2026-01-01T00:00:00Z",
  "updatedAt": "2026-01-01T00:00:00Z"
}
```

**Error Responses:**
- `404 Not Found`: Budget not found

**Example:**
```bash
curl http://localhost:5000/api/budgets/1
```

---

#### POST /api/budgets

Create a new budget.

**Request Body:**
```json
{
  "name": "Monthly Budget - February 2026",
  "totalAmount": 5500.00,
  "startDate": "2026-02-01T00:00:00Z",
  "endDate": "2026-02-28T00:00:00Z",
  "userId": "demo-user"
}
```

**Response:** `201 Created`
```json
{
  "id": 2,
  "name": "Monthly Budget - February 2026",
  "totalAmount": 5500.00,
  "startDate": "2026-02-01T00:00:00Z",
  "endDate": "2026-02-28T00:00:00Z",
  "userId": "demo-user",
  "createdAt": "2026-01-02T00:00:00Z",
  "updatedAt": "2026-01-02T00:00:00Z"
}
```

**Example:**
```bash
curl -X POST http://localhost:5000/api/budgets \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Monthly Budget - February 2026",
    "totalAmount": 5500.00,
    "startDate": "2026-02-01T00:00:00Z",
    "endDate": "2026-02-28T00:00:00Z",
    "userId": "demo-user"
  }'
```

---

#### PUT /api/budgets/{id}

Update an existing budget.

**Path Parameters:**
- `id` (required): Budget ID

**Request Body:**
```json
{
  "name": "Updated Budget Name",
  "totalAmount": 6000.00,
  "startDate": "2026-01-01T00:00:00Z",
  "endDate": "2026-01-31T00:00:00Z"
}
```

**Response:** `204 No Content`

**Error Responses:**
- `404 Not Found`: Budget not found

**Example:**
```bash
curl -X PUT http://localhost:5000/api/budgets/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Budget Name",
    "totalAmount": 6000.00,
    "startDate": "2026-01-01T00:00:00Z",
    "endDate": "2026-01-31T00:00:00Z"
  }'
```

---

#### DELETE /api/budgets/{id}

Delete a budget.

**Path Parameters:**
- `id` (required): Budget ID

**Response:** `204 No Content`

**Error Responses:**
- `404 Not Found`: Budget not found

**Example:**
```bash
curl -X DELETE http://localhost:5000/api/budgets/1
```

---

### Transactions

#### GET /api/transactions

Get all transactions, optionally filtered by budget.

**Query Parameters:**
- `budgetId` (optional): Filter transactions by budget ID

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "description": "Salary",
    "amount": 5000.00,
    "date": "2026-01-01T00:00:00Z",
    "type": "Income",
    "budgetId": 1,
    "categoryId": null,
    "createdAt": "2026-01-01T00:00:00Z"
  },
  {
    "id": 2,
    "description": "Grocery Store",
    "amount": 120.50,
    "date": "2026-01-03T00:00:00Z",
    "type": "Expense",
    "budgetId": 1,
    "categoryId": 1,
    "createdAt": "2026-01-03T00:00:00Z"
  }
]
```

**Example:**
```bash
curl http://localhost:5000/api/transactions?budgetId=1
```

---

#### GET /api/transactions/{id}

Get a specific transaction by ID.

**Path Parameters:**
- `id` (required): Transaction ID

**Response:** `200 OK`
```json
{
  "id": 1,
  "description": "Salary",
  "amount": 5000.00,
  "date": "2026-01-01T00:00:00Z",
  "type": "Income",
  "budgetId": 1,
  "categoryId": null,
  "createdAt": "2026-01-01T00:00:00Z"
}
```

**Error Responses:**
- `404 Not Found`: Transaction not found

---

#### POST /api/transactions

Create a new transaction.

**Request Body:**
```json
{
  "description": "Restaurant Dinner",
  "amount": 85.00,
  "date": "2026-01-15T00:00:00Z",
  "type": "Expense",
  "budgetId": 1,
  "categoryId": 3
}
```

**Response:** `201 Created`
```json
{
  "id": 6,
  "description": "Restaurant Dinner",
  "amount": 85.00,
  "date": "2026-01-15T00:00:00Z",
  "type": "Expense",
  "budgetId": 1,
  "categoryId": 3,
  "createdAt": "2026-01-15T00:00:00Z"
}
```

**Example:**
```bash
curl -X POST http://localhost:5000/api/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Restaurant Dinner",
    "amount": 85.00,
    "date": "2026-01-15T00:00:00Z",
    "type": "Expense",
    "budgetId": 1,
    "categoryId": 3
  }'
```

---

#### PUT /api/transactions/{id}

Update an existing transaction.

**Path Parameters:**
- `id` (required): Transaction ID

**Request Body:**
```json
{
  "description": "Updated Description",
  "amount": 95.00,
  "date": "2026-01-15T00:00:00Z",
  "type": "Expense",
  "categoryId": 3
}
```

**Response:** `204 No Content`

**Error Responses:**
- `404 Not Found`: Transaction not found

---

#### DELETE /api/transactions/{id}

Delete a transaction.

**Path Parameters:**
- `id` (required): Transaction ID

**Response:** `204 No Content`

**Error Responses:**
- `404 Not Found`: Transaction not found

**Example:**
```bash
curl -X DELETE http://localhost:5000/api/transactions/1
```

---

## Health Check

#### GET /health

Check the health of the API and its dependencies.

**Response:** `200 OK`
```json
{
  "status": "Healthy",
  "totalDuration": "00:00:00.0123456"
}
```

**Example:**
```bash
curl http://localhost:5000/health
```

---

## Error Responses

All endpoints may return the following error responses:

### 400 Bad Request
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "One or more validation errors occurred.",
  "status": 400,
  "errors": {
    "Name": ["The Name field is required."]
  }
}
```

### 404 Not Found
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.4",
  "title": "Not Found",
  "status": 404
}
```

### 500 Internal Server Error
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.6.1",
  "title": "An error occurred while processing your request.",
  "status": 500
}
```

---

## Interactive API Documentation

Visit `/swagger` when running the API to access interactive Swagger UI documentation where you can:
- Explore all endpoints
- Try out API calls directly
- View request/response schemas
- Download OpenAPI specification

**Example:** http://localhost:5000/swagger
