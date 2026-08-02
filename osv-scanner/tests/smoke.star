# osv-scanner/tests/smoke.star — stable across upstream releases, and OFFLINE.
# Assert on the contract (exit code, version shape, CLI surface), never on
# banner or help prose. Google reworks the table output and the banners freely;
# the digits, the exit codes and the flag names are the contract.
OSV = "osv-scanner.exe" if ocx.target_platform.os == ocx.os.Windows else "osv-scanner"

# Tier 1 + 2: liveness + version SHAPE (not a vendor string, not the exact
# version). osv-scanner prints its version to stdout on every release in range.
r_version = ocx.run(OSV, "--version")
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# Tier 3: the CLI surface, hermetically.
#
# There is deliberately NO scan here. Every scan path osv-scanner offers needs
# either the OSV API or a previously downloaded local database — `--offline`
# against a real lockfile exits 127 ("no offline version of the OSV database is
# available", measured on v2.0.0 and v2.4.0 with the network namespace cut),
# and seeding that database requires `--download-offline-databases`, i.e.
# network. Container legs may have no egress, so a scan would be a flake, not a
# test. What IS hermetic and stable across the whole 2.x range: the
# `scan source` subcommand resolves, exits 0 on --help, and advertises the
# flags this mirror's users invoke. A renamed subcommand or a dropped flag —
# the changes that would actually break a consumer — fail this.
# NOTE: do NOT assert the exit code here. osv-scanner CHANGED it mid-range —
# `scan source --help` exits 127 on 2.3.3 and 0 on 2.4.0 (both measured), while
# printing the same help to stdout either way. The exit code of a --help call is
# not this tool's contract; the subcommand resolving and advertising its flags
# is. Asserting exit 0 reds every backfilled 2.3.x for a cosmetic upstream
# change, which is exactly the "assert the contract, not the prose" trap.
r_help = ocx.run(OSV, "scan", "source", "--help")
expect.contains(r_help.stdout, "--lockfile")
expect.contains(r_help.stdout, "--offline")

# Tier 4: osv-scanner is a self-contained static binary — PATH only (proven by
# Tier 1). No non-PATH env var to wire, so no further Tier 4 check.
