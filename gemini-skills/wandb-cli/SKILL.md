---
name: wandb-cli
description: Use the wandb CLI and Python SDK to interact with W&B projects, list runs, get sweep results, and manage artifacts.
---

# WandB CLI Skill

Use the `wandb` CLI and the W&B Python SDK (`wandb.Api`) to query and manage W&B projects.
The CLI handles sweep lifecycle; the Python SDK handles run/metric/artifact queries.

## Step 1: Identify Entity and Project

Most operations require `entity` (team or username) and `project` name.
- Check `wandb status` if unknown.
- Common pattern: `ENTITY/PROJECT`.

## Step 2: Map Request to Section

| User intent | Section |
|---|---|
| List runs in a project, filter by status/config | **A: List & Filter Runs** |
| Get metrics / config for a specific run | **B: Single Run Inspection** |
| List sweeps, get sweep results, best run | **C: Sweeps** |
| Download or list artifacts | **D: Artifacts** |
| Compare multiple runs (table) | **E: Run Comparison** |
| Manage sweep state (stop/cancel/pause/resume) | **F: Sweep Lifecycle** |

## Section A: List & Filter Runs (Python SDK)

```python
import wandb
api = wandb.Api()
runs = api.runs("<ENTITY>/<PROJECT>", filters={"state": "finished"}, order="-created_at")
for run in runs:
    print(run.id, run.name, run.state, run.summary.get("accuracy"))
```

## Section B: Single Run Inspection (Python SDK)

```python
import wandb, json
api = wandb.Api()
run = api.run("<ENTITY>/<PROJECT>/<RUN_ID>")
print("Config:", json.dumps(dict(run.config), indent=2))
print("Summary:", json.dumps(dict(run.summary), indent=2))
```

## Section C: Sweeps (Python SDK)

```python
import wandb
api = wandb.Api()
sweep = api.sweep("<ENTITY>/<PROJECT>/<SWEEP_ID>")
print("Best run ID:", sweep.best_run().id if sweep.best_run() else "none")
```

## Section D: Artifacts (CLI & Python)

```bash
wandb artifact ls <ENTITY>/<PROJECT>
wandb artifact get <ENTITY>/<PROJECT>/<ARTIFACT_NAME>:<VERSION>
```

## Section E: Run Comparison (Python SDK)

Fetch multiple runs and present a table. Bold the best value in each metric column.

## Section F: Sweep Lifecycle (CLI)

```bash
wandb sweep --stop --project <PROJECT> --entity <ENTITY> <SWEEP_ID>
wandb sweep --pause --project <PROJECT> --entity <ENTITY> <SWEEP_ID>
```

## Step 3: Execute and Present Results

- Run Python snippets with `python3 -c "..."` via the Bash tool.
- Parse stdout and format results as markdown tables.
- Always show the run URL when inspecting a single run.
- If `wandb.Api()` raises an auth error, tell the user to run `wandb login` interactively.
