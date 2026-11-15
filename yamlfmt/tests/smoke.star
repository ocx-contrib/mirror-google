# yamlfmt/tests/smoke.star — OFFLINE and hermetic. Asserts the contract (exit
# codes, the formatted result), never help/version prose.
#
# Deliberately FILE-driven: `ocx.run(stdin=...)` is a pipe, and a formatter
# that prefers stdin over a file argument would render empty at exit 0.

YAMLFMT = "yamlfmt.exe" if ocx.target_platform.os == ocx.os.Windows else "yamlfmt"

# ── Tier 1 + 2: liveness + version SHAPE ────────────────────────────────────
# `-version` exists from v0.10.0 (the version floor). Output shape varies
# ("0.10.0" vs "yamlfmt 0.21.0 (sha)"), so only the digits are the contract.
r_version = ocx.run(YAMLFMT, "-version")
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# ── Tier 3: lint red -> format -> lint green ────────────────────────────────
# The input is badly spaced on purpose: wide gaps, a flow sequence with extra
# spaces, and a block sequence at the wrong indent.
ocx.write_file("t.yaml", "b:   2\na: [1,   2]\nlist:\n- x\n-   y\n")

# Negative control: an unformatted file must FAIL -lint, otherwise the green
# lint below would prove nothing.
expect.ne(ocx.run(YAMLFMT, "-lint", "t.yaml").exit_code, 0)

# Format in place, then the same file must satisfy -lint ...
expect.ok(ocx.run(YAMLFMT, "t.yaml"))
expect.ok(ocx.run(YAMLFMT, "-lint", "t.yaml"))

# ... and read back as exactly the normalised document (keys keep their order).
# yamlfmt writes the platform line ending (CRLF on Windows, measured in CI), so
# normalise before comparing; the content is the contract, not the EOL.
expect.eq(ocx.read_file("t.yaml").replace("\r\n", "\n"), "b: 2\na: [1, 2]\nlist:\n  - x\n  - y\n")

# ── Tier 3b: invalid YAML must be rejected, not echoed ──────────────────────
ocx.write_file("bad.yaml", "a: [unclosed\n")
expect.ne(ocx.run(YAMLFMT, "bad.yaml").exit_code, 0)
