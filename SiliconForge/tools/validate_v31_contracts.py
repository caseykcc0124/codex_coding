#!/usr/bin/env python3
"""Check v3.1 publication consistency only; this does NOT prove runtime/EDA success."""
from __future__ import annotations

import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "manifests" / "ACCEPTANCE_TRACKER_TEMPLATE.json"
CSV = ROOT / "manifests" / "ACCEPTANCE_TRACKER_TEMPLATE.csv"
CONTRACT = ROOT / "manifests" / "EXPLORATION_EVENT_CONTRACT.json"
DOCS = [
    "docs/12_PARALLEL_EXPLORATION_ARCHITECTURE.md",
    "docs/13_PARALLEL_EXPLORATION_ACCEPTANCE.md",
    "docs/14_PARALLEL_EXPLORATION_IMPLEMENTATION.md",
    "spec/SiliconForge_v3_1_Implementation_Baseline.md",
    "config/exploration.yaml",
]


def main() -> None:
    tracker = json.loads(MANIFEST.read_text(encoding="utf-8"))
    cases = tracker["cases"]
    ids = [c["case_id"] for c in cases]
    expected = [f"{prefix}{i:02d}" for prefix, n in
                (("A", 16), ("B", 14), ("C", 16), ("D", 12), ("E", 20))
                for i in range(1, n + 1)]
    assert len(cases) == tracker["total_required"] == 78
    assert len(set(ids)) == 78
    assert set(ids) == set(expected), f"missing={set(expected)-set(ids)} extra={set(ids)-set(expected)}"
    assert all(c["required"] is True for c in cases)
    assert all(c["status"] in {"NOT_RUN", "PASS", "FAIL", "BLOCKED"} for c in cases)
    with CSV.open(encoding="utf-8", newline="") as handle:
        csv_rows = list(csv.DictReader(handle))
    assert {r["case_id"] for r in csv_rows} == set(ids), "CSV/JSON cases differ"
    contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
    assert "BRANCH.FORK_REQUESTED" in contract["scoped_events"]
    assert "BRANCH.MERGE_REVERIFY_REQUIRED" in contract["scoped_events"]
    assert "owner_instance_id" in contract["fields"]
    for path in DOCS:
        assert (ROOT / path).is_file(), path
    policy = (ROOT / "config" / "exploration.yaml").read_text(encoding="utf-8")
    for key in (
        "max_initial_branches_per_exploration",
        "max_total_branches_per_exploration",
        "max_branch_depth",
        "require_post_merge_regate",
        "fair_scheduling_across_branches",
    ):
        assert key in policy, key
    routes = (ROOT / "config" / "routes.yaml").read_text(encoding="utf-8")
    for key in (
        "EXPLORATION.REQUESTED", "BRANCH.FORK_REQUESTED",
        "BRANCH.CANDIDATE_READY", "BRANCH.MERGE_REVERIFY_REQUIRED",
        "owner_instance_resolution",
    ):
        assert key in routes, key
    print("PASS: v3.1 specification, routing and 78-case tracker are internally consistent.")
    print("NOT RUN: no actual Codex, Git branch integration or EDA acceptance was executed.")


if __name__ == "__main__":
    main()
