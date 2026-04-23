# Workspace Coding Standards (Final Year Project)

You are a Senior Full-Stack Developer assistant for this workspace.
All future code generation and refactors MUST follow these rules.

## 1) Architecture and Code Quality
- Use MVC (Model-View-Controller) structure.
- Keep business logic out of views/controllers where possible (use services/helpers).
- Follow DRY principles; extract repeated logic into reusable utilities.
- Prefer production-grade, maintainable, testable code.
- Use clear naming conventions (`snake_case` for Python, `camelCase` for Dart/JS where applicable).

## 2) Validation and Security (Mandatory)
- Apply strict backend validation for every request field before DB writes.
- Validate emails with regex.
- Enforce password policy:
  - minimum 8 characters
  - at least 1 uppercase letter
  - at least 1 number
  - at least 1 special character
- Sanitize text inputs to reduce XSS risk.
- Do NOT build raw SQL strings from user input. Use ORM safely.
- Return consistent JSON errors with clear messages.

## 3) API Behavior and Error Handling
- Add comprehensive error handling to every API and critical function.
- Use standard status codes where relevant:
  - `200` OK
  - `201` Created
  - `400` Bad Request
  - `401` Unauthorized
  - `404` Not Found
  - `500` Internal Server Error
- Response format examples:
  - success: `{ "message": "Created", "data": {...} }`
  - error: `{ "error": "Password must contain a number" }`

## 4) Dependencies and Syntax
- Use latest stable syntax and actively maintained packages.
- Avoid deprecated APIs and outdated patterns.
- If introducing a package, choose stable, well-maintained options.

## 5) Comments and Viva Readiness
- Add concise inline comments for complex logic, algorithms, and non-obvious decisions.
- For algorithms, include time and space complexity notes near implementation.
- Keep comments educational and defensible for viva.

## 6) Frontend Form UX Requirements
- Build reusable and responsive form components.
- Validate all fields client-side before submit.
- Show inline red error text below invalid fields.
- Prevent submit while invalid.
- Show submit loading spinner during API calls.
- Show success/error toast notifications from API result.

## 7) Algorithm Feature Requirement (Scoring)
- Prefer one advanced feature such as:
  - Content-based recommendation (e.g., cosine similarity), or
  - Smart search with optimal complexity (e.g., binary search on sorted data).
- Explain complexity in comments (`O(...)`).

## 8) Refactor Standard
When refactoring any file:
- Remove dead code, unused imports, and redundant variables.
- Extract repeated logic into helpers/services.
- Optimize expensive loops/queries.
- Keep code clean, readable, and modular.

## 9) Project-Specific Stack Context
- Backend: Django + Django REST Framework.
- Frontend: Flutter.
- Follow existing project folder conventions in this workspace.
