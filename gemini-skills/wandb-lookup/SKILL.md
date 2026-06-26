---
name: wandb-lookup
description: Query WandB for experiment results, model comparisons, and registry status using MCP tools.
---

# WandB Lookup Skill

Query WandB runs, metrics, and the model registry using the WandB MCP tools.

## Step 1: Determine Lookup Type

Identify what the user wants:

| Request | Lookup type |
|---------|-------------|
| "show me run abc123" / specific run ID | **Single run** |
| "best run", "compare last N runs", "what improved" | **Run comparison** |
| "latest model", "what's in registry", "promoted version" | **Model registry** |
| "what project is this?" / first-time | **Project discovery** |

## Step 2: Discover Projects (if needed)

If the project or entity is unknown, list available WandB projects:

Use `mcp__wandb__query_wandb_entity_projects` to list projects for the entity.

## Step 3: Query Based on Lookup Type

### Single Run Lookup
Use `mcp__wandb__query_wandb_tool` with a query targeting the specific run ID or name.

### Run Comparison
Use `mcp__wandb__query_wandb_tool` to fetch the N most recent runs (default: 10) or matching a filter.

### Model Registry Lookup
Use `mcp__wandb__query_wandb_tool` to query the model registry.

### Traces (aih-nlp-autocoding inference monitoring)
Use `mcp__wandb__query_weave_traces_tool` and `mcp__wandb__count_weave_traces_tool`.

## Step 4: Format Results

### Single Run Report
Format with tables for Config and Metrics. Include Artifacts.

### Run Comparison Table
Include Rank (⭐ for best), Run ID, and key metrics.

### Registry Report
Show Latest Registered Version and Previous Versions.

## Quality Bar
- Always present metrics as a table, not prose.
- Highlight the best value in each metric column (bold or ⭐).
- Note the trend direction (improving / declining / stable).
- If a run failed or was aborted, flag it clearly.
