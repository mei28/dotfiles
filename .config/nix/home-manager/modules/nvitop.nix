# nvitop (NVIDIA GPU process viewer) for non-NixOS Linux hosts.
# nixpkgs' nvitop cannot find the driver's libnvidia-ml.so.1 outside NixOS:
# nix's glibc ignores /etc/ld.so.cache, and nixpkgs' pynvml only falls back to
# NixOS's /run/opengl-driver/lib. The wrapper asks the host's ldconfig for the
# library on every run, so no per-host driver path is configured here, and
# preloads that one file.
# Not LD_LIBRARY_PATH on the driver's directory: that directory also holds the
# host's libc, which would then be loaded into nix's Python.
{ pkgs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;

  # Architecture tag that `ldconfig -p` prints for 64-bit entries, as in
  # "libnvidia-ml.so.1 (libc6,x86-64) => /lib/x86_64-linux-gnu/libnvidia-ml.so.1".
  ldconfigArch =
    {
      x86_64-linux = "x86-64";
    }
    .${system} or (throw "nvitop: unsupported system ${system}");

  nvitop = pkgs.writeShellApplication {
    name = "nvitop";
    runtimeInputs = [ pkgs.gawk ];
    # /sbin/ldconfig, not one from PATH: nix's ldconfig reads nix's own cache.
    text = ''
      nvml=$(/sbin/ldconfig -p | awk '
        $1 == "libnvidia-ml.so.1" && $2 ~ /${ldconfigArch}/ && !found { print $NF; found = 1 }
      ')
      if [ -z "$nvml" ]; then
        echo "nvitop: libnvidia-ml.so.1 (${ldconfigArch}) is not in the ldconfig cache; is the NVIDIA driver installed?" >&2
        exit 1
      fi
      LD_PRELOAD="$nvml''${LD_PRELOAD:+:$LD_PRELOAD}" exec ${pkgs.nvitop}/bin/nvitop "$@"
    '';
  };
in
{
  home.packages = [ nvitop ];
}
