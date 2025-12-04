# SaxonC Libs

SaxonC Libs packages the pre-built SaxonC native libraries for use
from Ruby gems such as [`saxonc`](../saxon-rb). It offers a single
command that downloads the official SaxonC distribution for the
current platform, extracts the `lib`, `include`, and `bin` artifacts,
and stores them in a predictable location other gems can depend on.

## Versioning

This gem mirrors SaxonC releases using the pattern
`<saxon-version>.<packaging-patch>`. For example, version `12.9.0`
wraps SaxonC `12.9` with a first packaging revision. Whenever SaxonC
publishes a new point release, bump the first two segments and reset
the packaging patch to zero.

## Usage

```sh
gem install saxonc-libs
saxonc-libs install --target vendor/saxonc --edition he
```

The install command will:

1. Detect the current platform (macOS ARM64, macOS Intel, Linux
   x86_64, or Windows x86_64 for the initial release).
2. Read the release manifest for the bundled SaxonC version and
   edition (`he`, `pe`, or `ee`).
3. Download the official SaxonC zip archive for that platform.
4. Extract the relevant files into
   `vendor/saxonc/<edition>/<platform>`.
5. Write a manifest JSON file describing the extracted payload.

The CLI accepts `--edition` (defaults to `he`) and `--force` (to
re-download even if a cached copy exists), which is handy when testing
different SaxonC editions or refreshing a corrupted cache.

Other gems (such as `saxonc`) can then look up the installation path via:

```ruby
require "saxonc/libs"
saxon_home = SaxonC::Libs.install(edition: :he)
# => /path/to/vendor/saxonc/he/macos-arm64
```

## Release manifests

The `releases.yml` file in the repo root describes where to download
each platform artifact. The installer refuses to run unless a manifest
entry exists for the detected platform and edition. Publishing a new
packaging release typically involves:

1. Adding/updating the relevant section inside `releases.yml`.
2. Recording the download URL and SHA256 checksum for each platform.
3. Updating `lib/saxonc/libs/version.rb` with the new version.
4. Releasing the gem.

You can populate missing SHA256 values automatically via
`script/fill_checksums.rb`. Run it without options to download each
archive and compute its digest, or pass `--source-dir` to point at a
directory containing previously downloaded zips (useful for PE/EE
editions that require credentials):

```sh
bundle exec ruby script/fill_checksums.rb --source-dir ~/Downloads/saxonc
```

## License

This helper gem is distributed under the MIT license. The downloaded
SaxonC binaries remain subject to Saxonica's license terms; the
installer copies their notices alongside the extracted artifacts.
