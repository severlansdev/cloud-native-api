"""
Tests for the Items CRUD API.

Covers the full lifecycle: create, read, list, delete.
Also tests error cases (404 on missing items).
"""

import pytest

from app.routers.items import _items


@pytest.fixture(autouse=True)
def clear_items_store():
    """Clear the in-memory store before each test for isolation."""
    _items.clear()
    yield
    _items.clear()


@pytest.mark.asyncio
async def test_list_items_empty(client):
    """Listing items when store is empty should return an empty list."""
    response = await client.get("/api/v1/items/")
    assert response.status_code == 200
    assert response.json() == []


@pytest.mark.asyncio
async def test_create_item(client):
    """Creating an item should return 201 with the item data and a generated ID."""
    payload = {"name": "Test Widget", "description": "A test item", "price": 19.99}
    response = await client.post("/api/v1/items/", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Test Widget"
    assert data["price"] == 19.99
    assert "id" in data


@pytest.mark.asyncio
async def test_create_item_invalid_price(client):
    """Creating an item with a negative price should return 422."""
    payload = {"name": "Bad Item", "price": -5.00}
    response = await client.post("/api/v1/items/", json=payload)
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_create_and_get_item(client):
    """Creating then retrieving an item should return the same data."""
    payload = {"name": "Gadget", "description": "Cool gadget", "price": 49.99}
    create_resp = await client.post("/api/v1/items/", json=payload)
    item_id = create_resp.json()["id"]

    get_resp = await client.get(f"/api/v1/items/{item_id}")
    assert get_resp.status_code == 200
    assert get_resp.json()["name"] == "Gadget"


@pytest.mark.asyncio
async def test_get_item_not_found(client):
    """Getting a non-existent item should return 404."""
    response = await client.get("/api/v1/items/nonexistent-id")
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_delete_item(client):
    """Deleting an existing item should return 204 and remove it."""
    payload = {"name": "Temporary", "price": 9.99}
    create_resp = await client.post("/api/v1/items/", json=payload)
    item_id = create_resp.json()["id"]

    delete_resp = await client.delete(f"/api/v1/items/{item_id}")
    assert delete_resp.status_code == 204

    get_resp = await client.get(f"/api/v1/items/{item_id}")
    assert get_resp.status_code == 404


@pytest.mark.asyncio
async def test_delete_item_not_found(client):
    """Deleting a non-existent item should return 404."""
    response = await client.delete("/api/v1/items/nonexistent-id")
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_list_items_after_creation(client):
    """Listing items after creating two should return both."""
    await client.post("/api/v1/items/", json={"name": "Item A", "price": 10.00})
    await client.post("/api/v1/items/", json={"name": "Item B", "price": 20.00})

    response = await client.get("/api/v1/items/")
    assert response.status_code == 200
    items = response.json()
    assert len(items) == 2
