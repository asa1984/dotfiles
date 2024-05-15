{ rustPlatform, ... }:
rustPlatform.buildRustPackage {
  name = "hypr-helper";
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;
}
