import pytest
from httpx import AsyncClient


class TestRegister:
    async def test_register_success(self, client: AsyncClient):
        resp = await client.post(
            "/api/v1/auth/register",
            json={
                "full_name": "Karim Uddin",
                "email": "karim@poultry.bd",
                "password": "securepass123",
            },
        )
        assert resp.status_code == 201
        body = resp.json()
        assert body["status"] == "success"
        assert "access_token" in body["data"]
        assert "refresh_token" in body["data"]
        assert body["data"]["user"]["email"] == "karim@poultry.bd"
        assert body["data"]["user"]["role"] == "farmer"

    async def test_register_duplicate_email(self, client: AsyncClient):
        await client.post(
            "/api/v1/auth/register",
            json={
                "full_name": "First User",
                "email": "dup@poultry.bd",
                "password": "securepass123",
            },
        )
        resp = await client.post(
            "/api/v1/auth/register",
            json={
                "full_name": "Second User",
                "email": "dup@poultry.bd",
                "password": "anotherpass123",
            },
        )
        assert resp.status_code == 409
        assert resp.json()["error"]["code"] == "CONFLICT"

    async def test_register_short_password(self, client: AsyncClient):
        resp = await client.post(
            "/api/v1/auth/register",
            json={
                "full_name": "Test",
                "email": "short@poultry.bd",
                "password": "short",
            },
        )
        assert resp.status_code == 422

    async def test_register_invalid_email(self, client: AsyncClient):
        resp = await client.post(
            "/api/v1/auth/register",
            json={
                "full_name": "Test",
                "email": "not-an-email",
                "password": "securepass123",
            },
        )
        assert resp.status_code == 422

    async def test_register_with_role(self, client: AsyncClient):
        resp = await client.post(
            "/api/v1/auth/register",
            json={
                "full_name": "Dr. Rahman",
                "email": "vet@poultry.bd",
                "password": "securepass123",
                "role": "veterinarian",
                "language_pref": "bn",
            },
        )
        assert resp.status_code == 201
        assert resp.json()["data"]["user"]["role"] == "veterinarian"
        assert resp.json()["data"]["user"]["language_pref"] == "bn"


class TestLogin:
    async def test_login_success(self, client: AsyncClient):
        await client.post(
            "/api/v1/auth/register",
            json={
                "full_name": "Login Test",
                "email": "login@poultry.bd",
                "password": "securepass123",
            },
        )
        resp = await client.post(
            "/api/v1/auth/login",
            json={"email": "login@poultry.bd", "password": "securepass123"},
        )
        assert resp.status_code == 200
        body = resp.json()
        assert body["status"] == "success"
        assert "access_token" in body["data"]

    async def test_login_wrong_password(self, client: AsyncClient):
        await client.post(
            "/api/v1/auth/register",
            json={
                "full_name": "Wrong Pass",
                "email": "wrongpass@poultry.bd",
                "password": "securepass123",
            },
        )
        resp = await client.post(
            "/api/v1/auth/login",
            json={"email": "wrongpass@poultry.bd", "password": "badpassword"},
        )
        assert resp.status_code == 401

    async def test_login_nonexistent_email(self, client: AsyncClient):
        resp = await client.post(
            "/api/v1/auth/login",
            json={"email": "ghost@poultry.bd", "password": "whatever"},
        )
        assert resp.status_code == 401


class TestRefresh:
    async def test_refresh_returns_new_tokens(self, client: AsyncClient):
        reg = await client.post(
            "/api/v1/auth/register",
            json={
                "full_name": "Refresh Test",
                "email": "refresh@poultry.bd",
                "password": "securepass123",
            },
        )
        refresh_token = reg.json()["data"]["refresh_token"]

        resp = await client.post(
            "/api/v1/auth/refresh",
            json={"refresh_token": refresh_token},
        )
        assert resp.status_code == 200
        body = resp.json()
        assert body["data"]["access_token"] != reg.json()["data"]["access_token"]
        assert body["data"]["refresh_token"] != refresh_token

    async def test_refresh_invalid_token(self, client: AsyncClient):
        resp = await client.post(
            "/api/v1/auth/refresh",
            json={"refresh_token": "invalid.jwt.token"},
        )
        assert resp.status_code == 401


class TestLogout:
    async def test_logout_success(self, client: AsyncClient):
        reg = await client.post(
            "/api/v1/auth/register",
            json={
                "full_name": "Logout Test",
                "email": "logout@poultry.bd",
                "password": "securepass123",
            },
        )
        token = reg.json()["data"]["access_token"]
        resp = await client.post(
            "/api/v1/auth/logout",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert resp.status_code == 200

    async def test_logout_without_token(self, client: AsyncClient):
        resp = await client.post("/api/v1/auth/logout")
        assert resp.status_code in (401, 403)


class TestProtectedEndpoint:
    async def test_access_protected_without_token(self, client: AsyncClient):
        resp = await client.get("/api/v1/users/me")
        assert resp.status_code in (401, 403)

    async def test_access_protected_with_token(self, client: AsyncClient, auth_headers):
        resp = await client.get("/api/v1/users/me", headers=auth_headers)
        assert resp.status_code == 200
