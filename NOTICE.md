# NOTICE

This repository packages and redistributes upstream software published by
[Google](https://github.com/google). The Apache-2.0 license in
[`LICENSE`](LICENSE) covers the OCX pipeline files authored here. It does
**not** cover any upstream-derived asset — each package's redistributed bytes
carry their own license, recorded below.

Each package's logo is reproduced for catalog identification only, under
nominative fair use. The marks remain the property of their respective owners
and no endorsement is implied.

| Package | GHCR path | Upstream SPDX |
|---|---|---|
| `osv-scanner` | `ghcr.io/ocx-contrib/google/osv-scanner` | `Apache-2.0` |
| `crane` | `ghcr.io/ocx-contrib/google/crane` | `Apache-2.0` |
| `ko` | `ghcr.io/ocx-contrib/google/ko` | `Apache-2.0` |

---

## `osv-scanner`

Upstream: <https://github.com/google/osv-scanner>
Published to `ghcr.io/ocx-contrib/google/osv-scanner`.

| Component | SPDX | Holder |
|---|---|---|
| OSV-Scanner (`osv-scanner`) | **Apache-2.0** | Copyright Google LLC |

Permissive; redistribution of the compiled binary is granted under the terms of
<https://github.com/google/osv-scanner/blob/main/LICENSE>. Upstream ships raw
binaries with no bundled `LICENSE` file, so the terms are referenced here
rather than travelling with the artifact. The published binaries statically
link third-party Go modules under permissive licenses, enumerated in upstream's
`go.mod`.

The OSV-Scanner name and logo are trademarks of Google LLC, used for catalog
identification under nominative fair use.

No modifications are made to any upstream artifact in this repository; they are
republished byte-for-byte inside an OCX bundle.

---

## `crane`

Upstream: <https://github.com/google/go-containerregistry>
Published to `ghcr.io/ocx-contrib/google/crane`.

| Component | SPDX | Holder |
|---|---|---|
| crane, gcrane, krane | **Apache-2.0** | Copyright Google LLC |

Permissive; redistribution of the compiled binaries is granted under the terms
of
<https://github.com/google/go-containerregistry/blob/main/LICENSE>.
Verified via `gh api repos/google/go-containerregistry/license` →
`Apache-2.0`. Unlike osv-scanner, upstream ships the `LICENSE` file **inside**
every release archive, so the terms travel with the redistributed bytes as
well as being referenced here.

All three binaries are pure-Go static builds that link third-party Go modules
under permissive licenses, enumerated in upstream's `go.mod`.

The go-containerregistry name and the crane logo are marks of Google LLC, used
for catalog identification under nominative fair use.

No modifications are made to any upstream artifact in this repository; they are
republished byte-for-byte inside an OCX bundle.

---

## `ko`

Upstream: <https://github.com/google/ko>
Published to `ghcr.io/ocx-contrib/google/ko`.

| Component | SPDX | Holder |
|---|---|---|
| ko (`ko`) | **Apache-2.0** | Copyright Google LLC |

Permissive; redistribution of the compiled binary is granted under the terms of
<https://github.com/google/ko/blob/main/LICENSE>. Verified via
`gh api repos/google/ko/license` → `Apache-2.0`. As with crane, upstream ships
the `LICENSE` file **inside** every release archive, so the terms travel with
the redistributed bytes as well as being referenced here.

The binary is a pure-Go static build that links third-party Go modules under
permissive licenses, enumerated in upstream's `go.mod`.

ko is a CNCF Sandbox project; the ko name and logo are used for catalog
identification under nominative fair use.

No modifications are made to any upstream artifact in this repository; they are
republished byte-for-byte inside an OCX bundle.
