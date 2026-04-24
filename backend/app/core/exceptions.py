class AppException(Exception):
    def __init__(
        self,
        status_code: int,
        error_code: str,
        message: str,
        details: list | None = None,
    ):
        self.status_code = status_code
        self.error_code = error_code
        self.message = message
        self.details = details
        super().__init__(message)


class NotFoundError(AppException):
    def __init__(self, resource: str):
        super().__init__(404, "NOT_FOUND", f"{resource} not found")


class ValidationError(AppException):
    def __init__(self, message: str, details: list | None = None):
        super().__init__(422, "VALIDATION_ERROR", message, details)


class AuthenticationError(AppException):
    def __init__(self, message: str = "Authentication required"):
        super().__init__(401, "AUTHENTICATION_REQUIRED", message)


class AuthorizationError(AppException):
    def __init__(self, message: str = "Insufficient permissions"):
        super().__init__(403, "FORBIDDEN", message)


class ConflictError(AppException):
    def __init__(self, message: str):
        super().__init__(409, "CONFLICT", message)


class RateLimitError(AppException):
    def __init__(self, message: str = "Rate limit exceeded"):
        super().__init__(429, "RATE_LIMIT_EXCEEDED", message)
