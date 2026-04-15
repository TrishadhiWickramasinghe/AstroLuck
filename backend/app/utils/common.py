import uuid
from typing import Optional


def generate_uuid() -> str:
    """Generate a UUID"""
    return str(uuid.uuid4())


__all__ = ["generate_uuid"]
