import pytest
from services.expeditions import create_expedition, create_base, create_sample


def test_expedition_rejects_nonpositive_duration_before_database_access():
    with pytest.raises(ValueError, match="duración"):
        create_expedition(900, 1, "2026-11-22", 0, 10)


def test_expedition_rejects_nonpositive_capacity_before_database_access():
    with pytest.raises(ValueError, match="capacidad"):
        create_expedition(900, 1, "2026-11-22", 5, 0)


def test_base_requires_name_and_location_before_database_access():
    with pytest.raises(ValueError, match="obligatorios"):
        create_base("  ", "Antártida", 10, 1000, "Alto", 1)


def test_sample_requires_name_before_database_access():
    with pytest.raises(ValueError, match="obligatorio"):
        create_sample(" ", "desc", "2026-11-22", "Refrigerada", "Biológica", "Líquenes")


def test_sample_rejects_unknown_subtype_before_database_access():
    with pytest.raises(ValueError, match="clasificación"):
        create_sample("Muestra", "desc", "2026-11-22", "Refrigerada", "Química", "Dato")
