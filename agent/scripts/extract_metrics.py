#!/usr/bin/env python3
"""Extract summary metrics from a harness run.jsonl file.

Agents never edit metrics.jsonl directly. Experiment and verifier flows call
this script so summaries are reproducible from raw measurement events.
"""

from __future__ import annotations

import json
import statistics
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any


def load_events(path: Path) -> list[dict[str, Any]]:
    events: list[dict[str, Any]] = []
    with path.open("r", encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, start=1):
            line = line.strip()
            if not line:
                continue
            try:
                events.append(json.loads(line))
            except json.JSONDecodeError as exc:
                raise SystemExit(f"{path}:{line_number}: invalid JSON: {exc}") from exc
    return events


def extract(run_jsonl_path: Path, metrics_jsonl_path: Path) -> None:
    events = load_events(run_jsonl_path)
    metadata: dict[str, Any] = {}
    values: dict[tuple[str, str, str], list[float]] = defaultdict(list)

    for event in events:
        kind = event.get("event")
        if kind == "run_start":
            metadata = {
                key: event[key]
                for key in ("hypothesis_id", "experiment_id", "spec_hash", "git_commit")
                if key in event
            }
        elif kind == "measurement":
            missing = [
                key
                for key in ("method", "workload_id", "metric", "value")
                if key not in event
            ]
            if missing:
                raise SystemExit(f"measurement missing required fields: {missing}")
            key = (str(event["method"]), str(event["workload_id"]), str(event["metric"]))
            values[key].append(float(event["value"]))

    if not metadata:
        raise SystemExit("run.jsonl has no run_start metadata event")

    metrics_jsonl_path.parent.mkdir(parents=True, exist_ok=True)
    with metrics_jsonl_path.open("w", encoding="utf-8") as output:
        output.write(json.dumps({"event": "metadata", **metadata}, sort_keys=True) + "\n")
        for (method, workload_id, metric), samples in sorted(values.items()):
            record = {
                "event": "metric",
                "method": method,
                "workload_id": workload_id,
                "metric": metric,
                "n": len(samples),
                "mean": statistics.fmean(samples),
                "min": min(samples),
                "max": max(samples),
                "values": samples,
                **metadata,
            }
            if len(samples) > 1:
                record["stdev"] = statistics.stdev(samples)
            output.write(json.dumps(record, sort_keys=True) + "\n")


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print("usage: scripts/extract_metrics.py <run.jsonl> <metrics.jsonl>", file=sys.stderr)
        return 2
    extract(Path(argv[1]), Path(argv[2]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
