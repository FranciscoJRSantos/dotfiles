---
name: gitlab
description: Interact with GitLab using the `glab` CLI to manage merge requests, CI/CD pipelines, and issues.
---

# GitLab Skill (glab)

Use the `glab` CLI to interact with GitLab. All commands run in the current repo context unless
a `--repo OWNER/REPO` flag or `-g GROUP` flag is specified.

## Step 1: Understand the Request

Identify what the user wants. Map it to one of the sections below:

| User intent | Section |
|---|---|
| List/view MRs, review requests | Merge Requests |
| Check CI pipeline, job status, logs | CI/CD Pipelines |
| List/view/manage issues | Issues |
| Repo info, branches, contributors | Repository |
| Check auth / current user | Auth & Config |

If the user specifies a repo (e.g. `owner/repo` or a full URL), pass `--repo owner/repo` to all commands.

## Section A: Merge Requests

### List open MRs
```bash
glab mr list
```

### List MRs assigned to me
```bash
glab mr list --assignee=@me
```

### List MRs I need to review
```bash
glab mr list --reviewer=@me
```

### View a specific MR (by ID or current branch)
```bash
glab mr view <id>
# or for the current branch:
glab mr view
```

### View MR diff
```bash
glab mr diff <id>
```

### Approve an MR
```bash
glab mr approve <id>
```

### Merge an MR
```bash
glab mr merge <id>
```

### Add a comment to an MR
```bash
glab mr note <id> --message "Your comment here"
```

## Section B: CI/CD Pipelines

### Check pipeline status for current branch
```bash
glab ci status
```

### List recent pipelines
```bash
glab ci list
```

### View job logs (live tail)
```bash
glab job logs <job-id>
```
To find the job ID, first run `glab ci status` and note the job IDs shown.

### Retry a failed job
```bash
glab ci retry <job-id>
```

## Section C: Issues

### List open issues
```bash
glab issue list
```

### View a specific issue
```bash
glab issue view <id>
```

### Create an issue
```bash
glab issue create --title "Title here" --description "Description here"
```

## Section D: Repository

### View repo info
```bash
glab repo view
```

## Section E: Auth & Config

### Check current authenticated user and host
```bash
glab auth status
```

## Step 2: Run the Commands

Run the relevant command(s) using the Bash tool. Parse the output and present results clearly.

**Tips:**
- Use `--output=json` on supported commands to get structured data when you need to extract specific fields.
- When showing MR lists, summarize: MR ID, title, author, target branch, status, and pipeline status.
- When showing pipeline status, highlight failing jobs and their names.
- If a command fails because glab isn't authenticated (`glab auth status`), tell the user to run `glab auth login` interactively.

## Step 3: Present Results

Format output clearly using tables for lists and structured summaries for pipeline status.
Do not fabricate data.
