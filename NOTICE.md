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
