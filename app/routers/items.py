"""
Items router - Example CRUD endpoints.

Demonstrates a well-structured REST API with:
- Pydantic models for request/response validation
- Proper HTTP status codes
- In-memory store (swap for a real DB in production)
"""

from uuid import uuid4

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field

router = APIRouter(prefix="/api/v1/items", tags=["Items"])


# ---- Models ----

class ItemCreate(BaseModel):
    """Schema for creating a new item."""
    name: str = Field(..., min_length=1, max_length=100, examples=["Widget Alpha"])
    description: str = Field(default="", max_length=500, examples=["A premium widget"])
    price: float = Field(..., gt=0, examples=[29.99])


class ItemResponse(BaseModel):
    """Schema for item responses."""
    id: str
    name: str
    description: str
    price: float


# ---- In-Memory Store ----

_items: dict[str, dict] = {}


# ---- Endpoints ----

@router.get("/", response_model=list[ItemResponse], summary="List all items")
async def list_items():
    """Retrieve all items from the store."""
    return list(_items.values())


@router.post(
    "/",
    response_model=ItemResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create a new item",
)
async def create_item(item: ItemCreate):
    """Create a new item and return it with a generated ID."""
    item_id = str(uuid4())
    stored = {"id": item_id, **item.model_dump()}
    _items[item_id] = stored
    return stored


@router.get("/{item_id}", response_model=ItemResponse, summary="Get item by ID")
async def get_item(item_id: str):
    """Retrieve a specific item by its unique ID."""
    if item_id not in _items:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Item '{item_id}' not found",
        )
    return _items[item_id]


@router.delete(
    "/{item_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete an item",
)
async def delete_item(item_id: str):
    """Delete an item by its ID."""
    if item_id not in _items:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Item '{item_id}' not found",
        )
    del _items[item_id]
