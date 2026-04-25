from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from app.core.exceptions import AuthenticationError, ConflictError
from app.core.security import (
    create_access_token,
    decode_token,
    hash_password,
    verify_password,
)
from app.models.user import LanguagePreference, User, UserRole
from app.services.auth_service import AuthService


class TestPasswordHashing:
    def test_hash_password_returns_bcrypt(self):
        hashed = hash_password("testpass123")
        assert hashed.startswith("$2b$")

    def test_verify_password_correct(self):
        hashed = hash_password("mypassword")
        assert verify_password("mypassword", hashed) is True

    def test_verify_password_incorrect(self):
        hashed = hash_password("mypassword")
        assert verify_password("wrongpassword", hashed) is False


class TestJWT:
    def test_create_access_token_contains_claims(self):
        token, jti = create_access_token("user-123", "farmer", "en")
        payload = decode_token(token)
        assert payload["sub"] == "user-123"
        assert payload["role"] == "farmer"
        assert payload["lang"] == "en"
        assert payload["jti"] == jti

    def test_decode_token_expired(self):
        from datetime import datetime, timedelta, timezone

        import jwt

        payload = {
            "sub": "user-123",
            "exp": datetime.now(timezone.utc) - timedelta(hours=1),
            "jti": "test-jti",
        }
        from app.config import settings

        token = jwt.encode(payload, settings.JWT_SECRET_KEY, algorithm="HS256")
        with pytest.raises(Exception):
            decode_token(token)

    def test_decode_token_invalid(self):
        with pytest.raises(Exception):
            decode_token("invalid.token.here")


class TestAuthService:
    @pytest.fixture
    def auth_svc(self):
        return AuthService()

    @pytest.fixture
    def mock_db(self):
        return AsyncMock()

    @pytest.fixture
    def mock_redis(self):
        redis = AsyncMock()
        redis.get = AsyncMock(return_value=None)
        redis.setex = AsyncMock()
        return redis

    @pytest.fixture
    def mock_user(self):
        user = MagicMock(spec=User)
        user.id = "user-123"
        user.email = "test@example.com"
        user.password_hash = hash_password("correctpass")
        user.is_active = True
        user.role = UserRole.FARMER
        user.language_pref = LanguagePreference.EN
        return user

    @patch("app.services.auth_service.user_repo")
    @patch("app.services.auth_service.session_repo")
    async def test_register_success(self, mock_session_repo, mock_user_repo, auth_svc, mock_db):
        mock_user_repo.get_by_email = AsyncMock(return_value=None)
        new_user = MagicMock(spec=User)
        new_user.id = "new-user-id"
        new_user.role = UserRole.FARMER
        new_user.language_pref = LanguagePreference.EN
        mock_user_repo.create = AsyncMock(return_value=new_user)
        mock_session_repo.create = AsyncMock()

        user, access, refresh = await auth_svc.register(
            mock_db,
            full_name="Test",
            email="new@example.com",
            password="password123",
        )
        assert user == new_user
        assert access is not None
        assert refresh is not None
        mock_user_repo.create.assert_called_once()

    @patch("app.services.auth_service.user_repo")
    async def test_register_duplicate_email(self, mock_user_repo, auth_svc, mock_db):
        mock_user_repo.get_by_email = AsyncMock(return_value=MagicMock())
        with pytest.raises(ConflictError, match="Email already registered"):
            await auth_svc.register(
                mock_db, full_name="Test", email="dup@example.com", password="password123"
            )

    @patch("app.services.auth_service.user_repo")
    @patch("app.services.auth_service.session_repo")
    async def test_login_success(
        self, mock_session_repo, mock_user_repo, auth_svc, mock_db, mock_user
    ):
        mock_user_repo.get_by_email = AsyncMock(return_value=mock_user)
        mock_session_repo.create = AsyncMock()

        user, access, refresh = await auth_svc.login(
            mock_db, email="test@example.com", password="correctpass"
        )
        assert user == mock_user
        assert access is not None

    @patch("app.services.auth_service.user_repo")
    async def test_login_wrong_password(self, mock_user_repo, auth_svc, mock_db, mock_user):
        mock_user_repo.get_by_email = AsyncMock(return_value=mock_user)
        with pytest.raises(AuthenticationError, match="Invalid email or password"):
            await auth_svc.login(mock_db, email="test@example.com", password="wrongpass")

    @patch("app.services.auth_service.user_repo")
    async def test_login_nonexistent_user(self, mock_user_repo, auth_svc, mock_db):
        mock_user_repo.get_by_email = AsyncMock(return_value=None)
        with pytest.raises(AuthenticationError, match="Invalid email or password"):
            await auth_svc.login(mock_db, email="nobody@example.com", password="pass")

    @patch("app.services.auth_service.user_repo")
    async def test_login_inactive_user(self, mock_user_repo, auth_svc, mock_db, mock_user):
        mock_user.is_active = False
        mock_user_repo.get_by_email = AsyncMock(return_value=mock_user)
        with pytest.raises(AuthenticationError, match="Account is deactivated"):
            await auth_svc.login(mock_db, email="test@example.com", password="correctpass")

    @patch("app.services.auth_service.user_repo")
    @patch("app.services.auth_service.session_repo")
    async def test_logout_blacklists_token(
        self, mock_session_repo, mock_user_repo, auth_svc, mock_db, mock_redis, mock_user
    ):
        access_token, jti = create_access_token("user-123", "farmer", "en")
        mock_session_repo.revoke_all_for_user = AsyncMock(return_value=1)

        await auth_svc.logout(
            mock_db, mock_redis, user=mock_user, access_token=access_token
        )
        mock_redis.setex.assert_called_once()
        mock_session_repo.revoke_all_for_user.assert_called_once_with(mock_db, "user-123")

    @patch("app.services.auth_service.user_repo")
    @patch("app.services.auth_service.session_repo")
    async def test_refresh_rotation(
        self, mock_session_repo, mock_user_repo, auth_svc, mock_db, mock_redis, mock_user
    ):
        from app.core.security import create_refresh_token, hash_refresh_token

        refresh_token, refresh_jti = create_refresh_token("user-123")
        mock_session = MagicMock()
        mock_session.user_id = "user-123"
        mock_session.device_info = "test-device"
        mock_session_repo.get_by_token_hash = AsyncMock(return_value=mock_session)
        mock_session_repo.revoke = AsyncMock()
        mock_session_repo.create = AsyncMock()
        mock_user_repo.get_by_id = AsyncMock(return_value=mock_user)

        new_access, new_refresh = await auth_svc.refresh_tokens(
            mock_db, mock_redis, refresh_token_str=refresh_token
        )
        assert new_access is not None
        assert new_refresh is not None
        mock_session_repo.revoke.assert_called_once_with(mock_db, mock_session)

    @patch("app.services.auth_service.session_repo")
    async def test_refresh_revoked_token(
        self, mock_session_repo, auth_svc, mock_db, mock_redis
    ):
        from app.core.security import create_refresh_token

        refresh_token, _ = create_refresh_token("user-123")
        mock_session_repo.get_by_token_hash = AsyncMock(return_value=None)

        with pytest.raises(AuthenticationError, match="Refresh token revoked"):
            await auth_svc.refresh_tokens(
                mock_db, mock_redis, refresh_token_str=refresh_token
            )
