{ claude-code, fetchzip }:
claude-code.overrideAttrs (oldAttrs: rec {
  version = "1.0.27";
  src = fetchzip {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
    hash = "sha256-HnlJo93RfsZdUZiXfnojDjp3BVSBNJ3YX/6silX9VUU=";
  };
  npmDepsHash = "sha256-7jbvsIXulG6dJOnMc5MjDm/Kcyndm4jDSdj85eSp/hc=";
})
