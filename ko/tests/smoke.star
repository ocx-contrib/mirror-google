# ko/tests/smoke.star — stable across upstream releases, and OFFLINE.
# Assert on the contract (exit code, version shape, a real parse/emit round
# trip), never on help or banner prose.
#
# ko's headline job — build a Go program into a container image — is out of
# reach here twice over: it needs a Go toolchain (absent from the alpine,
# ubuntu and fedora container legs) and a registry to push to (legs may have no
# egress). `resolve` is the exception and the better test anyway: handed a
# manifest with no `ko://` reference it does the whole YAML pipeline — read,
# parse, walk for image references, re-emit — and touches neither Go nor the
# network.

KO = "ko.exe" if ocx.target_platform.os == ocx.os.Windows else "ko"

# ko refuses to construct a publisher without this, even when there is nothing
# to publish (measured: `Error: error creating publisher: KO_DOCKER_REPO
# environment variable is unset`, exit 1). The value is never contacted —
# `--push=false` below, and the manifest names no image to build.
KO_ENV = {"KO_DOCKER_REPO": "ocx.local/smoke"}

# ── Tier 1 + 2: liveness on the composed PATH + version SHAPE ───────────────
# `ko version` prints the bare version and nothing else (measured: stdout is
# exactly "0.19.1\n" on v0.19.1 and "0.18.1\n" on v0.18.1). The digits are the
# contract; the exact version is not.
r_version = ocx.run(KO, "version")
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# ── Tier 3a: a hermetic resolve round trip ──────────────────────────────────
# A ConfigMap with no `ko://` image reference must survive `ko resolve`
# unchanged. The marker value is arbitrary and ours, so it cannot be satisfied
# by anything but our own input coming back out.
ocx.write_file(
    "cm.yaml",
    "apiVersion: v1\nkind: ConfigMap\nmetadata:\n  name: ocx-smoke\ndata:\n  token: ocx-marker-42\n",
)

r_resolve = ocx.run(KO, "resolve", "--push=false", "-f", "cm.yaml", env=KO_ENV)
expect.ok(r_resolve)
expect.contains(r_resolve.stdout, "ocx-marker-42")
expect.contains(r_resolve.stdout, "kind: ConfigMap")
expect.contains(r_resolve.stdout, "name: ocx-smoke")

# ── Tier 3b: the negative control that makes 3a mean something ──────────────
# Passthrough alone would also be satisfied by `cat`. This input is not valid
# YAML — an unterminated flow mapping — so anything that actually PARSES must
# reject it. Measured non-zero on both v0.18.1 and v0.19.1. Without this pair,
# a binary that had lost its YAML machinery and merely echoed its input would
# still go green above.
ocx.write_file("invalid.yaml", "apiVersion: v1\nkind: ConfigMap\ndata: {token: unclosed\n")

r_invalid = ocx.run(KO, "resolve", "--push=false", "-f", "invalid.yaml", env=KO_ENV)
expect.ne(r_invalid.exit_code, 0)

# No Tier 4: metadata.json declares PATH only, and Tier 1 already proved it.
# KO_DOCKER_REPO above is this test's own scaffolding, not a bundle-declared
# var — nothing in metadata.json wires it, and nothing should.
