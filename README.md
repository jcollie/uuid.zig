<!-- SPDX-FileCopyrightText: © 2025 Jeffrey C. Ollie -->
<!-- SPDX-License-Identifier: MIT -->

# RFC 9562 UUIDs for Zig

A Zig library for generating, parsing, and formatting
[RFC 9562](https://www.rfc-editor.org/rfc/rfc9562.html) UUIDs.

The API documentation, generated from the doc comments in the source,
is published at <https://jeff.jcollie.page/zig-uuid/>.

## Features

- Generate version 1, 2, 3, 4, 5, 6, 7, and 8 UUIDs
- The special `nil` (all zeros) and `max` (all ones) UUIDs
- The well-known name space IDs (DNS, URL, OID, X.500) for creating
  v3 and v5 UUIDs
- Create v3 and v5 UUIDs straight from a name space and a name with
  `UUID.fromName`, which does the hashing; the name can be given in parts
- Parse and format the standard string representation
  (`c232ab00-9414-11ec-b3c8-9f6bdeced846`) and the URN representation
  (`urn:uuid:c232ab00-9414-11ec-b3c8-9f6bdeced846`)
- Parse and format the Windows registry form of a GUID — upper case, in
  braces (`{C232AB00-9414-11EC-B3C8-9F6BDECED846}`) — as Windows
  Installer and WiX use it; the hex case and the braces can also be
  chosen separately
- Implements `format` so UUIDs can be printed directly with `{f}`, and
  `fmt` to print them in any of the other forms
- `UUID` is a packed union that is exactly 128 bits — compare UUIDs
  with `a.id == b.id`, or access the version and variant fields via
  `meta`
- No allocations, no dependencies

## Source

The canonical repository is <https://git.jcollie.dev/jeff/zig-uuid>:

```sh
git clone https://git.jcollie.dev/jeff/zig-uuid.git
```

It is also on the Radicle network, where the repository's identifier is

```
rad:z3uZSgLiCAhT3BkqgaaoF1SKvye6s
```

and `rad clone rad:z3uZSgLiCAhT3BkqgaaoF1SKvye6s` fetches it from any
node that seeds it, needing no account and no forge. A further copy is
mirrored to <https://tangled.org/jcollie.dev/zig-uuid>. All three carry
the same history on `main`; the Forgejo one is where the tests and the
documentation build run.

## Requirements

Zig 0.17.0. The development shell takes the official release binary
from [zig-overlay](https://git.jcollie.dev/jeff/zig-overlay).

## Installation

Add the dependency to your project:

```sh
zig fetch --save git+https://git.jcollie.dev/jeff/zig-uuid
```

Then in your `build.zig`:

```zig
const uuid = b.dependency("uuid", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("uuid", uuid.module("uuid"));
```

## Examples

Generate a random (version 4) UUID:

```zig
const std = @import("std");
const UUID = @import("uuid").UUID;

pub fn main(init: std.process.Init) void {
    const rng_impl: std.Random.IoSource = .{ .io = init.io };
    const rng = rng_impl.interface();

    const uuid: UUID = .new(.{
        .v4 = .{
            .rng = rng,
        },
    });

    std.debug.print("{f}\n", .{uuid});
}
```

Generate a timestamp-based, sortable (version 7) UUID:

```zig
const uuid: UUID = .new(.{
    .v7 = .{
        .unix_ts_ms = .{ .timestamp = .now(io, .real) },
        .rng = rng,
    },
});
```

Generate a name-based (version 5) UUID. The digest is taken over the
name space and then each part of the name in turn, so the result is the
same as hashing the parts joined together:

```zig
const uuid: UUID = .fromName(.v5, .namespace_dns, &.{"www.example.com"});
// 2ed6657d-e927-568b-95e1-2665a8aea6a2

const component: UUID = .fromName(.v5, my_namespace, &.{ "component/", name });
```

`.v3` uses MD5 instead of SHA-1. If you already have the digest, pass it
to `UUID.new` in the `hash` field of the `.v3` or `.v5` options.

Parse and format:

```zig
const uuid = try UUID.deserialize("c232ab00-9414-11ec-b3c8-9f6bdeced846");
const str: [36]u8 = uuid.serialize();
const urn: [45]u8 = uuid.serializeUrn();
```

`deserialize` also accepts the braced form, in either case, and rejects
a brace without its partner. The Windows registry form is available
directly, or by choosing the case and the braces yourself:

```zig
const guid = try UUID.deserialize("{6BA7B810-9DAD-11D1-80B4-00C04FD430C8}");
const reg: [38]u8 = guid.serializeRegistry(); // {6BA7B810-9DAD-11D1-80B4-00C04FD430C8}
const upper: [36]u8 = guid.serializeOptions(.{ .case = .upper });
std.debug.print("{f}\n", .{guid.fmt(.registry)});
```

Version 2 (DCE
Security) UUIDs store only 28 bits of timestamp and 6 bits of clock
sequence, so UUIDs generated within the same ~7 minute window for the
same local ID collide easily — prefer another version unless you
specifically need DCE semantics.

## Standards

- [RFC 9562: Universally Unique IDentifiers (UUIDs)](https://www.rfc-editor.org/rfc/rfc9562.html)
  — the current UUID specification, which this library implements. It
  defines versions 1 and 3 through 8, the `nil` and `max` UUIDs, and
  the string and URN representations, and it obsoletes
  [RFC 4122](https://www.rfc-editor.org/rfc/rfc4122.html).
- [DCE 1.1: Authentication and Security Services](https://pubs.opengroup.org/onlinepubs/9696989899/chap5.htm#tagcjh_08_02_01_01)
  — the Open Group specification that defines version 2 "DCE Security"
  UUIDs. RFC 9562 reserves version 2 but leaves its definition here.

The test suite checks against the example values and test vectors from
RFC 9562, with the name-based v8 example corrected per
[erratum 7929](https://www.rfc-editor.org/errata/eid7929).

## Development

```sh
zig build test   # run the tests
zig build run    # run the example UUID generator
zig build docs   # build the API docs into zig-out/docs
zig build bench  # run the benchmarks (always ReleaseFast)
```

## License

MIT. This project follows the [REUSE](https://reuse.software/)
specification.
