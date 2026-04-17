{ rustPlatform, fetchFromGitHub, ... }:
rustPlatform.buildRustPackage rec {
  pname = "jquants-cli";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "J-Quants";
    repo = "jquants-cli";
    tag = "v${version}";
    hash = "sha256-GZ0edloqHnywdc7Mohq+L5hLQ073l7tfXMww+dLzBkY=";
  };
  cargoLock.lockFile = "${src}/Cargo.lock";
}
