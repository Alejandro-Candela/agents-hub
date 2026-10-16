"""Measure whether installed skills trigger on realistic prompts.

skill-creator's run_eval.py registers a temporary copy of the skill and watches
for that copy's name, so for a skill that is already installed it always reports
0%: the model calls the real skill instead. This runs plain `claude -p` and
checks which skill the model actually invokes.

Usage:
    uv run scripts/skill-trigger-eval.py cases.json [--runs 3] [--workers 8] [--model opus]

cases.json: [{"skill": "reddit-growth", "query": "...", "should_trigger": true}, ...]
"""

import argparse
import json
import subprocess
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path


def invoked_skills(query: str, model: str, cwd: Path) -> list[str]:
    result = subprocess.run(
        ["claude", "-p", "--model", model, "--max-turns", "2", "--output-format", "stream-json", "--verbose", query],
        capture_output=True,
        text=True,
        cwd=cwd,
    )
    skills: list[str] = []
    for line in result.stdout.splitlines():
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        if event.get("type") != "assistant":
            continue
        for block in event.get("message", {}).get("content", []):
            if block.get("type") == "tool_use" and block.get("name") == "Skill":
                skills.append(block.get("input", {}).get("skill", ""))
    return skills


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("cases", type=Path)
    parser.add_argument("--runs", type=int, default=1)
    parser.add_argument("--workers", type=int, default=8)
    parser.add_argument("--model", default="opus")
    args = parser.parse_args()

    cases = json.loads(args.cases.read_text())
    jobs = [case for case in cases for _ in range(args.runs)]
    repo = Path(__file__).resolve().parent.parent

    with ThreadPoolExecutor(args.workers) as pool:
        results = list(pool.map(lambda c: invoked_skills(c["query"], args.model, repo), jobs))

    hits: dict[tuple[str, str], int] = defaultdict(int)
    for case, skills in zip(jobs, results):
        hits[(case["skill"], case["query"])] += case["skill"] in skills

    score: dict[str, list[int]] = defaultdict(lambda: [0, 0])
    for case in cases:
        rate = hits[(case["skill"], case["query"])]
        passed = (rate > args.runs / 2) == case["should_trigger"]
        score[case["skill"]][0] += passed
        score[case["skill"]][1] += 1
        if not passed:
            print(f"MISS {case['skill']} expected={case['should_trigger']} triggered={rate}/{args.runs}: {case['query'][:90]}")
    for skill, (passed, total) in sorted(score.items()):
        print(f"SCORE {skill}: {passed}/{total}")


if __name__ == "__main__":
    main()
