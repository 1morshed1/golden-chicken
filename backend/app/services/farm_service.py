from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import AuthorizationError, NotFoundError
from app.models.farm import Farm, Shed
from app.models.user import User
from app.repositories.farm_repository import FarmRepository, ShedRepository

farm_repo = FarmRepository()
shed_repo = ShedRepository()


class FarmService:
    async def get_user_farms(self, db: AsyncSession, user: User) -> list[Farm]:
        return await farm_repo.get_user_farms(db, str(user.id))

    async def get_farm(self, db: AsyncSession, farm_id: str, user: User) -> Farm:
        farm = await farm_repo.get_farm_with_sheds(db, farm_id)
        if not farm or not farm.is_active:
            raise NotFoundError("Farm")
        self._check_ownership(farm, user)
        return farm

    async def create_farm(self, db: AsyncSession, user: User, **kwargs) -> Farm:
        return await farm_repo.create(db, user_id=user.id, **kwargs)

    async def update_farm(
        self, db: AsyncSession, farm_id: str, user: User, **kwargs
    ) -> Farm:
        farm = await self._get_owned_farm(db, farm_id, user)
        update_data = {k: v for k, v in kwargs.items() if v is not None}
        if not update_data:
            return farm
        return await farm_repo.update(db, farm, **update_data)

    async def delete_farm(
        self, db: AsyncSession, farm_id: str, user: User
    ) -> None:
        farm = await self._get_owned_farm(db, farm_id, user)
        await farm_repo.soft_delete(db, farm)

    async def get_farm_sheds(
        self, db: AsyncSession, farm_id: str, user: User
    ) -> list[Shed]:
        await self._get_owned_farm(db, farm_id, user)
        return await shed_repo.get_farm_sheds(db, farm_id)

    async def create_shed(
        self, db: AsyncSession, farm_id: str, user: User, **kwargs
    ) -> Shed:
        await self._get_owned_farm(db, farm_id, user)
        return await shed_repo.create(db, farm_id=farm_id, **kwargs)

    async def get_shed(self, db: AsyncSession, shed_id: str, user: User) -> Shed:
        shed = await shed_repo.get_by_id(db, shed_id)
        if not shed or not shed.is_active:
            raise NotFoundError("Shed")
        farm = await farm_repo.get_by_id(db, shed.farm_id)
        if not farm:
            raise NotFoundError("Farm")
        self._check_ownership(farm, user)
        return shed

    async def update_shed(
        self, db: AsyncSession, shed_id: str, user: User, **kwargs
    ) -> Shed:
        shed = await self.get_shed(db, shed_id, user)
        update_data = {k: v for k, v in kwargs.items() if v is not None}
        if not update_data:
            return shed
        return await shed_repo.update(db, shed, **update_data)

    async def delete_shed(
        self, db: AsyncSession, shed_id: str, user: User
    ) -> None:
        shed = await self.get_shed(db, shed_id, user)
        await shed_repo.soft_delete(db, shed)

    async def _get_owned_farm(
        self, db: AsyncSession, farm_id: str, user: User
    ) -> Farm:
        farm = await farm_repo.get_by_id(db, farm_id)
        if not farm or not farm.is_active:
            raise NotFoundError("Farm")
        self._check_ownership(farm, user)
        return farm

    def _check_ownership(self, farm: Farm, user: User) -> None:
        if str(farm.user_id) != str(user.id):
            raise AuthorizationError("You don't own this farm")


farm_service = FarmService()
