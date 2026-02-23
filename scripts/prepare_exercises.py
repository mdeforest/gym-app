#!/usr/bin/env python3
"""
Fetches Free Exercise DB, maps to Pulse's schema, and outputs exercises.json.

Usage:
    python3 scripts/prepare_exercises.py > Pulse/Resources/exercises.json

Data structure from Free Exercise DB:
    {
      "name": "Barbell Bench Press",
      "category": "strength",          # strength | cardio | stretching | ...
      "equipment": "barbell",           # string (not array)
      "primaryMuscles": ["chest"],      # array of strings
      "instructions": ["Step 1...", "Step 2..."],
      ...
    }

The Free Exercise DB is public domain (Unlicense).
Source: https://github.com/yuhonas/free-exercise-db
"""

import json
import sys
import urllib.request
from collections import Counter

SOURCE_URL = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json"

# Include only these category types
INCLUDED_CATEGORIES = {"strength", "cardio"}

# Map primaryMuscles values → Pulse MuscleGroup raw values.
# The first matching muscle in primaryMuscles determines the group.
MUSCLE_MAP = {
    "chest":       "chest",
    "abdominals":  "core",
    "abs":         "core",
    "core":        "core",
    "shoulders":   "shoulders",
    "traps":       "back",
    "lats":        "back",
    "middle back": "back",
    "lower back":  "back",
    "upper back":  "back",
    "back":        "back",
    "triceps":     "arms",
    "biceps":      "arms",
    "forearms":    "arms",
    "quadriceps":  "legs",
    "hamstrings":  "legs",
    "calves":      "legs",
    "glutes":      "legs",
    "legs":        "legs",
    "hip flexors": "legs",
    "adductors":   "legs",
    "abductors":   "legs",
}

# Map Free Exercise DB equipment strings → Pulse Equipment raw values.
EQUIPMENT_MAP = {
    "barbell":         "barbell",
    "dumbbell":        "dumbbell",
    "dumbbells":       "dumbbell",
    "cable":           "cable",
    "machine":         "machine",
    "body only":       "bodyweight",
    "body weight":     "bodyweight",
    "bodyweight":      "bodyweight",
    "kettlebells":     "kettlebell",
    "kettlebell":      "kettlebell",
    "bands":           "bands",
    "band":            "bands",
    "resistance band": "bands",
    "e-z curl bar":    "barbell",
    "ez curl bar":     "barbell",
    "ez-curl bar":     "barbell",
    "foam roll":       "other",
    "medicine ball":   "other",
    "exercise ball":   "other",
    "other":           "other",
    "":                "other",
}

# Default rest seconds by muscle group
DEFAULT_REST_MAP = {
    "cardio": 60,
    "core":   60,
}
DEFAULT_REST_STRENGTH = 90


def map_muscle_group(primary_muscles: list, category: str):
    if category == "cardio":
        return "cardio"
    for muscle in primary_muscles:
        mapped = MUSCLE_MAP.get(muscle.lower().strip())
        if mapped:
            return mapped
    return None  # can't map — skip this exercise


def map_equipment(equipment_str: str) -> str:
    return EQUIPMENT_MAP.get((equipment_str or "").lower().strip(), "other")


def build_instructions(steps: list) -> str:
    return "\n".join(f"{i + 1}. {s.strip()}" for i, s in enumerate(steps) if s.strip())


def build_description(primary_muscles: list, muscle_group: str) -> str:
    if primary_muscles:
        muscles_str = ", ".join(m.capitalize() for m in primary_muscles)
        return f"Targets the {muscles_str}."
    return f"A {muscle_group} exercise."


def main():
    print("Fetching Free Exercise DB...", file=sys.stderr)
    with urllib.request.urlopen(SOURCE_URL) as response:
        raw = json.loads(response.read())
    print(f"Fetched {len(raw)} total exercises.", file=sys.stderr)

    seen_names: set = set()
    output = []
    skipped_category = 0
    skipped_no_muscle = 0
    skipped_duplicate = 0

    for ex in raw:
        category = (ex.get("category") or "").lower().strip()

        if category not in INCLUDED_CATEGORIES:
            skipped_category += 1
            continue

        name = (ex.get("name") or "").strip()
        if not name:
            continue
        if name in seen_names:
            skipped_duplicate += 1
            continue

        primary_muscles = ex.get("primaryMuscles") or []
        muscle_group = map_muscle_group(primary_muscles, category)
        if muscle_group is None:
            skipped_no_muscle += 1
            continue

        seen_names.add(name)

        is_cardio = muscle_group == "cardio"
        equipment = map_equipment(ex.get("equipment") or "")
        instructions = build_instructions(ex.get("instructions") or [])
        description = build_description(primary_muscles, muscle_group)
        default_rest = DEFAULT_REST_MAP.get(muscle_group, DEFAULT_REST_STRENGTH)

        output.append({
            "name": name,
            "muscleGroup": muscle_group,
            "isCardio": is_cardio,
            "defaultRestSeconds": default_rest,
            "description": description,
            "instructions": instructions,
            "equipment": equipment,
        })

    # Sort alphabetically by name
    output.sort(key=lambda x: x["name"].lower())

    print(json.dumps(output, indent=2, ensure_ascii=False))

    # Stats to stderr
    print(f"\nDone. Total exercises output: {len(output)}", file=sys.stderr)
    print(f"Skipped (excluded category): {skipped_category}", file=sys.stderr)
    print(f"Skipped (no muscle mapping): {skipped_no_muscle}", file=sys.stderr)
    print(f"Skipped (duplicate name): {skipped_duplicate}", file=sys.stderr)

    groups = Counter(e["muscleGroup"] for e in output)
    print("\nBy muscle group:", file=sys.stderr)
    for group, count in sorted(groups.items()):
        print(f"  {group}: {count}", file=sys.stderr)

    equips = Counter(e["equipment"] for e in output)
    print("\nBy equipment:", file=sys.stderr)
    for eq, count in sorted(equips.items()):
        print(f"  {eq}: {count}", file=sys.stderr)


if __name__ == "__main__":
    main()
