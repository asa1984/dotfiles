{ claude-code, fetchzip }:
claude-code.overrideAttrs (oldAttrs: rec {
  version = "1.0.51";
  src = fetchzip {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
    hash = "sha256-sAILRsi8ZViMfcpqykfnFQzHTJHRwRSZz45otMqa4U0=";
  };
  npmDepsHash = "sha256-7jbvsIXulG6dJOnMc5MjDm/Kcyndm4jDSdj85eSp/hc=";
})
