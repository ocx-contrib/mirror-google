# mirror-google

OCX mirrors for tools published by [Google](https://github.com/google). One
repository, one spec directory per package.

| Package | Spec | Publishes to | Announced as | Upstream SPDX |
|---|---|---|---|---|
| [OSV-Scanner](https://github.com/google/osv-scanner) | [`osv-scanner/mirror.yml`](osv-scanner/mirror.yml) | `ghcr.io/ocx-contrib/google/osv-scanner` | `ocx.sh/google/osv-scanner` | `Apache-2.0` |
| [crane](https://github.com/google/go-containerregistry) | [`crane/mirror.yml`](crane/mirror.yml) | `ghcr.io/ocx-contrib/google/crane` | `ocx.sh/google/crane` | `Apache-2.0` |
| [ko](https://github.com/google/ko) | [`ko/mirror.yml`](ko/mirror.yml) | `ghcr.io/ocx-contrib/google/ko` | `ocx.sh/google/ko` | `Apache-2.0` |

Each upstream release is discovered, re-bundled, smoke-tested per
`(version, platform)` and only then pushed with cascade tags, after which the
result is announced into the OCX index.

> This repository previously published the same upstream to the flat coordinate
> `ocx.sh/osv-scanner` as `mirror-osv-scanner`. `google/osv-scanner` is the
> grouped successor; the repository is named for the vendor namespace so it can
> later carry other Google-published tools.

## Layout

```
mirror-base.yml         repo-wide policy every spec inherits via `extends:`
osv-scanner/            one directory per package — same five files each
crane/
ko/
├── mirror.yml          the spec — never at the repo root
├── metadata.json       bundle interface
├── CATALOG.md          → ocx package describe
├── logo.svg / logo.png describe assets, 512px PNG
└── tests/smoke.star    Starlark smoke test
```

`LICENSE` and `NOTICE.md` are shared at the root. Logos are **not** — each
package carries its own, because a repo-root `logo.*` sits in no workflow's
`paths:` filter, so replacing it would publish nothing until some unrelated
edit happened to fire.

⚠️ `extends:` is a **shallow** merge of top-level keys. A spec that restates
`platforms:` to change one runner drops every `containers:` entry with it, and
nothing reds — the legs simply stop existing, and every `os.features` claim
goes back to being asserted rather than verified. Restate a block in full or
not at all.

## Platforms

`osv-scanner` publishes six platform entries: both Linux arches, both macOS
arches and both Windows arches — everything upstream builds. Upstream compiles
it as a pure-Go binary without cgo, so there is one Linux build per arch and it
is **fully static** — no `PT_INTERP`, no `DT_NEEDED`, and no musl/glibc
variants to choose between. `os.features` states what an artifact requires *of
the host*, so both Linux keys are **bare**: tagging them `+libc.musl` would be
a false requirement that hid them from every glibc host. The `alpine:3.20`
container leg in `mirror-base.yml` is what turns that claim into evidence; the
measurement itself is recorded above the `assets:` block in
`osv-scanner/mirror.yml`.

`crane` measures the same way — pure-Go, cgo-free, no `PT_INTERP` and no
`DT_NEEDED` on either arch for any of its three binaries (evidence above its
`assets:` block), so both its Linux keys are bare with the alpine leg attached.
It publishes all six platforms — linux, darwin and windows on amd64 and arm64
— rolled out in three staged passes (linux, then darwin, then windows), each
its own commit and CI run.

Both `crane` and `ko` restate `platforms:` in full rather than inheriting
`mirror-base.yml`'s block, and that is deliberate. Staging only the `assets:`
keys does **not** save runner minutes: the generated test matrix is static, so
a platform declared with no matching asset still boots its `macos-14` /
`windows-11-arm` runner, skips every version and reports **success** having
tested nothing. The `platforms:` entry has to be commented out too, and
uncommented in the same edit as its assets.

The other arches upstream builds — `armv6`, `i386`, `mips64le`, `ppc64le`,
`riscv64`, `s390x`, `loong64` — are not carried, and that is not a policy
call: OCX's architecture enum has only `amd64` and `arm64`, so they cannot be
expressed as platform keys at all.

`ko` measures the same way and ships under the same staging, with one extra
hazard of its own: **every ko release publishes each platform twice**, once as
`ko_<version>_<OS>_<arch>.tar.gz` and once as an unversioned twin
`ko_<OS>_<arch>.tar.gz`. A pattern that does not demand a literal semver token
right after `ko_` matches both and fails the version with an ambiguous
`>1 match`. The patterns in `ko/mirror.yml` therefore carry
`\d+\.\d+\.\d+` and are anchored at both ends.

The version floor is `2.0.0`. Below it upstream had not settled on versionless
asset names (v1.4.0 ships `osv-scanner_1.4.0_linux_amd64`, which the anchored
patterns match zero times — a green run with no platforms), and the v1 CLI has
no `scan source` subcommand for the smoke test to assert.

## Editing

| File | Edit | Regenerate after |
|------|------|------------------|
| `mirror-base.yml`, `<pkg>/mirror.yml` | hand | yes — see below |
| `<pkg>/{metadata.json,CATALOG.md,logo.*}` | hand | — |
| `<pkg>/tests/smoke.star` | hand | — |
| `.github/workflows/*.yml` | **generated — never hand-edit** | re-run when a spec changes |

```bash
ocx-mirror package pipeline generate ci \
  --spec osv-scanner/mirror.yml \
  --spec crane/mirror.yml \
  --spec ko/mirror.yml
```

**Name every spec.** `--spec` *appends* rather than replaces, so a command
naming a subset silently stops rendering the rest while staying green — and the
drift guard reds on a generated workflow the current spec set no longer
produces.

`verify-generated.yml` exits 65 on drift. If a generated workflow is wrong, the
spec or the renderer template is wrong — fix it there and regenerate.

Run `direnv allow` once to put the pinned toolchain on `PATH`, and invoke
`ocx-mirror` directly — never `ocx run -- ocx-mirror`, which pins
`OCX_BINARY_PIN` to the bootstrap `ocx` and false-reds the nested push.

## The binaries claim

osv-scanner ships as a raw binary, so the bundle's only PATH entry is a bare
`${installPath}` — the executable *is* the content root. `bin_scan` only looks
*below* an `${installPath}/<dir>` entry, so `auto`/`verify` is rejected at spec
load with exit 65. `mirror-base.yml` therefore sets `bin_scan: off` and
`osv-scanner/metadata.json` hand-lists `binaries: ["osv-scanner"]` — the
blessed shape for this asset type.

`crane` reaches the same place from the other direction: its archives are
**flat**, with `LICENSE`, `README.md` and the executables all at the archive
root and no wrapper directory, so `strip_components: 0` puts them at the
content root and PATH is again a bare `${installPath}`. That archive bundles
**three** executables — `crane`, `gcrane` and `krane` — and all three land on
PATH, so all three are declared. Declaring only `crane` would misrepresent the
bundle's surface exactly as a fabricated entry would; `crane/tests/smoke.star`
runs all three and asserts they report the same version.

## The smoke test is offline

Every osv-scanner scan path needs either the OSV API or a database seeded by an
earlier `--download-offline-databases` run; `--offline` on a bare runner exits
127. Container legs may have no egress, so `tests/smoke.star` asserts the
version *shape* and the `scan source` CLI surface rather than a scan result.

## Required secrets

| Secret | Use |
|--------|-----|
| `OCX_ANNOUNCE_TOKEN` | opens the index pull request from the `ocx-contrib/index` fork |
| `OCX_MIRROR_DISCORD_HOOK` | notify-stage Discord webhook URL |

(Inherited from the `ocx-contrib` org with visibility ALL. GHCR pushes use the
run's own `GITHUB_TOKEN` — no registry secret needed.)

## License

Apache-2.0 — see [`LICENSE`](LICENSE). Upstream assets are out of scope; each
package's redistribution license is recorded in [`NOTICE.md`](NOTICE.md).
