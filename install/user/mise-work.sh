# Setup default work directory (and tries)
source "$OMARCHY_INSTALL/helpers/capability-outcomes.sh"
capability_outcomes_require_emitter || return $?

mkdir -p "$HOME/Work"
mkdir -p "$HOME/Work/tries"

cat >"$HOME/Work/.mise.toml" <<'EOF'
[env]
_.path = "{{ cwd }}/bin"
EOF

mise trust ~/Work/.mise.toml

# Offline installs unpack the Node tarball bundled by the ISO: from
# /opt/packages in the ISO chroot, or from the copy staged in provisioning state when
# omarchy-provision-owner finalizes the user at first boot.
case ${OMARCHY_SETUP_CONTEXT:-runtime} in
  iso-chroot) NODE_PACKAGE_DIR=/opt/packages ;;
  provision-owner) NODE_PACKAGE_DIR=/var/lib/omarchy/provisioning/packages ;;
  *) NODE_PACKAGE_DIR="" ;;
esac

# Node ships per-architecture tarballs, and Apple Silicon needs the arm64 one.
case $(uname -m) in
  aarch64) NODE_TARBALL_ARCH=arm64 ;;
  *) NODE_TARBALL_ARCH=x64 ;;
esac

NODE_TARBALL=""
if [[ -n $NODE_PACKAGE_DIR ]]; then
  NODE_TARBALL=$(find "$NODE_PACKAGE_DIR" -name "node-v*-linux-${NODE_TARBALL_ARCH}.tar.gz" -type f 2>/dev/null | head -n1)
fi

if [[ -n $NODE_TARBALL ]]; then
  NODE_VERSION=$(basename "$NODE_TARBALL" | sed "s/node-v\(.*\)-linux-${NODE_TARBALL_ARCH}.tar.gz/\1/")
  NODE_INSTALL_DIR="$HOME/.local/share/mise/installs/node/$NODE_VERSION"

  if mkdir -p "$NODE_INSTALL_DIR" &&
    tar -xzf "$NODE_TARBALL" --strip-components=1 -C "$NODE_INSTALL_DIR" &&
    mise use -g node@"$NODE_VERSION"; then
    capability_valid node-runtime false "bundled Node.js $NODE_VERSION installed"
  else
    capability_optional_unavailable node-runtime "bundled Node.js installation failed"
  fi
else
  # Only the ISO stages a tarball, and --first-install reports iso-chroot even
  # for a script install, so a missing one is normal here rather than a broken
  # image. Never fail user setup over it.
  if [[ -n $NODE_PACKAGE_DIR ]]; then
    echo "No bundled Node.js tarball in $NODE_PACKAGE_DIR; installing from the network" >&2
  fi
  if mise use -g node@latest; then
    capability_valid node-runtime false "Node.js installed from the configured runtime source"
  else
    capability_optional_unavailable node-runtime "Node.js installation deferred because the runtime source is unavailable"
  fi
fi
