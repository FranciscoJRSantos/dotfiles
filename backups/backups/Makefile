# Restic backups of $HOME to Cloudflare R2 (dotfiles package `backups`, stowed to ~/backups).
#
#   make backup    back up $(BACKUP_PATH) minus excludes.txt
#   make prune     forget old snapshots (archive-tagged ones are kept) and reclaim space
#   make list      list snapshots (the default goal, read-only)
#   make check     verify the repository
#   make stats     repository statistics
#   make init      create the repository (once)
#   make restore   restore the latest snapshot into $(RESTORE_DIR)
#   make mount     browse every snapshot through FUSE until Ctrl-C
#   make creds     store the credentials for the daily timer (run-unattended.sh)
#
# No credentials live on disk. The four values below are 1Password references
# (item `restic-r2` with fields repository, access_key_id, secret_access_key and
# password); `op run` swaps each op:// value for the real one in restic's
# environment only. Another vault: `make OP_ITEM=op://<vault>/restic-r2 ...`.
# --no-masking keeps restic on the terminal, otherwise its progress display is lost.
# tests/backups.sh points the same recipes at a throwaway local repository with
# `make RESTIC=restic`, so the excludes and the retention are exercised for real.
#
# Interactive runs use op (1Password desktop approval). The daily timer cannot be approved by
# hand, so it reads systemd-creds copies instead (make creds, run-unattended.sh).

here        := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
OP_ITEM     ?= op://Private/restic-r2
BACKUP_PATH ?= $(HOME)
EXCLUDES    ?= $(here)excludes.txt
RESTORE_DIR ?= $(HOME)/restic-restore
MOUNT_DIR   ?= $(HOME)/mnt/backups
RESTIC      ?= env \
    RESTIC_REPOSITORY=$(OP_ITEM)/repository \
    AWS_ACCESS_KEY_ID=$(OP_ITEM)/access_key_id \
    AWS_SECRET_ACCESS_KEY=$(OP_ITEM)/secret_access_key \
    RESTIC_PASSWORD=$(OP_ITEM)/password \
    op run --no-masking -- restic

SHELL       := bash
OP          ?= op
CRED_DIR    ?= $(HOME)/.config/credstore.encrypted

.DEFAULT_GOAL := list
.PHONY: init backup prune list check stats restore mount creds

init:
	$(RESTIC) init

backup:
	$(RESTIC) backup $(BACKUP_PATH) --exclude-caches --exclude-file=$(EXCLUDES)

# A real-time window, not keep-daily/weekly: those count periods that HAVE snapshots, so manual runs stretch them over months.
prune:
	$(RESTIC) forget --keep-within 30d --keep-last 1 --keep-tag archive --prune

list:
	$(RESTIC) snapshots

check:
	$(RESTIC) check

stats:
	$(RESTIC) stats

# Restores outside this directory on purpose: it is a stow link into the dotfiles repo.
restore:
	mkdir -p $(RESTORE_DIR)
	$(RESTIC) restore latest --target $(RESTORE_DIR) --verbose

# Copy the four 1Password fields into systemd user credentials (encrypted, bound to this
# machine and user) for the timer's unattended runs, see run-unattended.sh. Rerun it after
# rotating the R2 token or reinstalling. Values go through a pipe, never a command line.
creds:
	@set -eo pipefail; umask 077; mkdir -p $(CRED_DIR); \
	for pair in restic-repository:repository aws-access-key-id:access_key_id \
	    aws-secret-access-key:secret_access_key restic-password:password; do \
	    name=$${pair%%:*}; field=$${pair#*:}; \
	    $(OP) read --no-newline "$(OP_ITEM)/$$field" \
	        | systemd-creds --user encrypt --name="$$name" - "$(CRED_DIR)/$$name"; \
	    echo "stored $$name"; \
	done

# -rmdir, never rm -rf: a mountpoint that is still busy must not be emptied.
mount:
	mkdir -p $(MOUNT_DIR)
	$(RESTIC) mount $(MOUNT_DIR)
	-rmdir $(MOUNT_DIR)
