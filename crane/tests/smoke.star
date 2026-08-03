# crane/tests/smoke.star — stable across upstream releases, and OFFLINE.
# Assert on the contract (exit code, version shape, a computed content
# address), never on help or banner prose. crane is a registry client, so every
# obvious subcommand needs a registry; container legs may have no egress, and a
# network-dependent assertion would be a flake, not a test. What IS hermetic:
# crane's local OCI-image machinery, which `append`/`validate`/`digest` reach
# through `--tarball` with no registry at all.

CRANE = "crane.exe" if ocx.target_platform.os == ocx.os.Windows else "crane"
GCRANE = "gcrane.exe" if ocx.target_platform.os == ocx.os.Windows else "gcrane"
KRANE = "krane.exe" if ocx.target_platform.os == ocx.os.Windows else "krane"

# ── Tier 1 + 2: liveness on the composed PATH + version SHAPE ───────────────
# `crane version` prints the bare version and nothing else (measured: stdout is
# exactly "0.21.8\n" on v0.21.8 and "0.21.6\n" on v0.21.6). The digits are the
# contract; the exact version is not.
r_version = ocx.run(CRANE, "version")
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# metadata.json claims THREE binaries on PATH, not one — this archive bundles
# crane, gcrane and krane, and a `binaries` claim is only honest if every entry
# in it actually resolves. Asserting they report the SAME version additionally
# proves all three came out of one upstream build, i.e. that the bundle was not
# assembled from mixed archives.
r_gcrane = ocx.run(GCRANE, "version")
expect.ok(r_gcrane)
expect.eq(r_gcrane.stdout, r_version.stdout)

r_krane = ocx.run(KRANE, "version")
expect.ok(r_krane)
expect.eq(r_krane.stdout, r_version.stdout)

# ── Tier 3: an offline, content-addressed round trip ────────────────────────
# Build an image from an empty layer, then read it back two ways. A zero-byte
# file is a valid (empty) tar stream, which is what `-f` expects; `--base` is
# deliberately omitted so crane synthesises an empty base image and the whole
# thing stays local. This exercises the real path: layer gzip + digest, config
# blob assembly, manifest construction, docker-tarball write — then a full
# re-read that re-digests every blob.
#
# `validate` is a genuine gate, not a formality: handed an image whose layer is
# not a tar it exits 1 with "undersized layer[0] content" (measured on v0.21.8),
# so a green here means the bytes crane wrote actually check out.
ocx.write_file("layer.tar", "")

r_append = ocx.run(
    CRANE, "append", "-f", "layer.tar", "-t", "ocx.local/smoke:v1", "-o", "img.tar",
)
expect.ok(r_append)
expect.true(ocx.exists("img.tar"))

r_validate = ocx.run(CRANE, "validate", "--tarball", "img.tar")
expect.ok(r_validate)

# Digest SHAPE, not the literal value. The digest is in fact stable — the same
# sha256 came out of v0.21.6 and v0.21.8 — but pinning it would red a future
# release for a legitimate change in how an empty image is serialised, which is
# not this mirror's contract. That crane computes a well-formed content address
# at all is.
r_digest = ocx.run(CRANE, "digest", "--tarball", "img.tar")
expect.ok(r_digest)
expect.matches(r_digest.stdout, r"^sha256:[0-9a-f]{64}")

# No Tier 4: metadata.json declares PATH only, and Tier 1 already proved it.
