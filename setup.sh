#!/bin/bash

# Exit script on any error
set -e

# --- Configuration ---
PACMAN_PKGLIST="pkglist.txt"
AUR_PKGLIST="aur_pkglist.txt"
AUR_HELPER="yay"
DOTFILES_DIR="$HOME/dotfiles"
STOW_PACKAGES=() 
STOW_TARGET_DIR="$HOME"

# --- Helper Functions ---
log_info() {
  echo -e "\033[1;34m[INFO]\033[0m $1"
}

log_success() {
  echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

log_warning() {
  echo -e "\033[1;33m[WARNING]\033[0m $1"
}

log_error() {
  echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
}

# --- Preliminary Checks ---
if [[ $EUID -eq 0 ]]; then
  log_error "This script should not be run as root. Sudo will be used for privileged commands."
  exit 1
fi

if ! command -v git &> /dev/null; then
  log_info "Git not found. Installing git..."
  sudo pacman -S --noconfirm --needed git
fi

if ! command -v stow &> /dev/null; then
  log_info "GNU Stow not found. Installing stow..."
  sudo pacman -S --noconfirm --needed stow
fi

# --- Package Installation ---
log_info "Starting package installation..."
log_info "Updating system..."
sudo pacman -Syu --noconfirm

# 2. Install official repository packages
if [ -f "$PACMAN_PKGLIST" ] && [ -s "$PACMAN_PKGLIST" ]; then
  log_info "Installing packages from $PACMAN_PKGLIST..."
  sudo pacman -S --noconfirm --needed - < "$PACMAN_PKGLIST"
  log_success "Official packages installed."
else
  log_warning "$PACMAN_PKGLIST not found or empty. Skipping official package installation."
fi

# 3. Install AUR packages (requires an AUR helper)
if [ -f "$AUR_PKGLIST" ] && [ -s "$AUR_PKGLIST" ]; then
  if ! command -v "$AUR_HELPER" &> /dev/null; then
    log_error "$AUR_HELPER (AUR helper) not found. Please install it first."
    log_info "For example, to install $AUR_HELPER (if it's yay):"
    log_info "  git clone https://aur.archlinux.org/yay.git /tmp/yay"
    log_info "  cd /tmp/yay && makepkg -si --noconfirm && cd -"
    exit 1
  fi
  log_info "Installing AUR packages from $AUR_PKGLIST using $AUR_HELPER..."
  "$AUR_HELPER" -S --noconfirm --needed - < "$AUR_PKGLIST"
  log_success "AUR packages installed."
else
  log_info "No $AUR_PKGLIST found or it's empty. Skipping AUR package installation."
fi

# --- Dotfiles Setup with GNU Stow ---
log_info "Setting up dotfiles with GNU Stow..."

if [ ! -d "$DOTFILES_DIR" ]; then
  log_error "Dotfiles directory ($DOTFILES_DIR) not found."
  log_info "Please clone your dotfiles repository first."
  log_info "Example: git clone <your-dotfiles-repo-url> $DOTFILES_DIR"
  exit 1
fi

# Change to the dotfiles directory to make stow commands simpler
cd "$DOTFILES_DIR"

if [ ${#STOW_PACKAGES[@]} -eq 0 ]; then
    log_info "No specific STOW_PACKAGES defined. Attempting to stow all directories..."
    # Stow all directories (excluding .git and other dot-prefixed files/dirs at the root of DOTFILES_DIR)
    for pkg in */; do
        pkg_name=$(basename "$pkg")
        if [[ "$pkg_name" == ".git" ]] || [[ "$pkg_name" == ".*" ]]; then # Skip .git and other hidden files/dirs
            log_info "Skipping $pkg_name..."
            continue
        fi
        log_info "Stowing ${pkg_name%/}" # Remove trailing slash for cleaner output
        stow -R -t "$STOW_TARGET_DIR" "${pkg_name%/}"
    done
else
    log_info "Stowing specified packages: ${STOW_PACKAGES[*]}"
    for pkg in "${STOW_PACKAGES[@]}"; do
        if [ -d "$pkg" ]; then
            log_info "Stowing $pkg..."
            stow -R -t "$STOW_TARGET_DIR" "$pkg"
        else
            log_warning "Stow package directory '$pkg' not found in $DOTFILES_DIR. Skipping."
        fi
    done
fi

cd - > /dev/null 

log_success "Dotfiles setup complete!"

log_success "System setup script finished!"
echo "You might need to reboot or log out/in for all changes to take effect (e.g., shell changes, font rendering)."
