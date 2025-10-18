{ claude-code, fetchzip }:
claude-code.overrideAttrs (oldAttrs: rec {
  version = "2.0.22";
  src = fetchzip {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
    hash = "sha256-SDXYXEb7Vi150Hx04y9kd+Owzu11VSqVRgej36P2khU=";
  };
  npmDepsHash = "sha256-7jbvsIXulG6dJOnMc5MjDm/Kcyndm4jDSdj85eSp/hc=";
})
