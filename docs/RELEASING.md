# Release POC

The desktop app connects to a separately running HTTPS Peek server. GitHub Actions
builds its installers and an instance-configured server image. This POC leaves public
publication disabled until the repository owner opts in. It does not deploy the server,
apply migrations or change the iPhone release process.

The desktop shell has its own version. The connected server supplies the web UI, so
testing a nightly shell against a stable server does not test nightly server code.
See [the desktop README](../desktop/README.md) for setup and client limitations.
OAuth/SSO handoff is not implemented: provider-only instances are not supported by this
client POC. Email-code sign-in uses the existing server flow.

## Validate without publishing

Changes to the release tooling and desktop app run **Release POC validation** on pull
requests. Fork contributions may need the repository owner to approve the workflow run.
The workflow uses read-only permissions and does not receive inherited signing secrets.
It produces explicitly unsigned installers and image archives as workflow artifacts.

From the repository root, with its supported Node version:

```sh
npm ci
npm run test:release
npm --prefix desktop ci
npm --prefix desktop run lint
npm --prefix desktop run typecheck
npm --prefix desktop test
npm --prefix desktop run test:smoke
```

The desktop smoke test uses synthetic local content. It does not prove that a particular
server's authentication or carrier-verification provider works. On Linux, Electron
also needs its system libraries and a display; CI runs the smoke under Xvfb.

Once the workflow files exist on the default branch, use **Run workflow** on
**Nightly release POC** or **Stable release POC**, leaving `publish` false. Stable runs
require a version matching the selected source commit's root `package.json`; an empty
`source_sha` selects the workflow's default-branch commit. Keep the run's plan, checksums
and installer artifacts together when validating a candidate.

## Channels and source identity

The nightly entry point has a daily UTC schedule and a manual trigger. Scheduled runs
stay disabled until publication is enabled. Nightlies skip a source that already
has a complete successful publication in either channel. A manual stable release can
promote the same source as a nightly. A failed attempt or draft does not advance the
baseline. All repository commits count as changes.

Nightlies use `<stable>-nightly.<run>.g<sha12>`. Before the first stable publication, the
committed package version is the provisional base. The manifest records the full SHA,
run and image identity. This stable-base prerelease sorts below its stable version;
stable and nightly use different desktop identities and profile directories. The POC
does not automatically update installed clients.

Stable releases are manual. Their version must increase, and a published version cannot
be rebound to different content. The workflows serialize planning, builds and publication
under a shared concurrency group. GitHub can replace a pending run; rerun a superseded
manual request if it is still wanted.

Native build numbers use each channel workflow's run number, capped at 65535. Do not
rename or recreate those workflows without planning how to preserve increasing native
versions. Rerunning an existing workflow retains its build number.

## Publication setup

The owner must validate the POC before setting `PEEK_RELEASE_PUBLISH_ENABLED=true`.
This enables scheduled publication; manual publication also requires `publish=true`
and a workflow dispatched from `main`. Configure the `peek-release` environment with
the desired approval and branch protections before enabling it.

The signing jobs need `CSC_LINK` and `CSC_KEY_PASSWORD` for macOS, `WIN_CSC_LINK` and
`WIN_CSC_KEY_PASSWORD` for Windows, and `APPLE_API_KEY_CONTENT`, `APPLE_API_KEY_ID`
and `APPLE_API_ISSUER` for notarization. `APPLE_API_KEY_CONTENT` is the `.p8` content;
the job writes it to a temporary file and removes it afterward. Missing required signing
configuration must fail publication rather than silently produce unsigned releases.

`PEEK_RELEASE_IMAGE_REPOSITORY` chooses the GHCR owner/package without the `ghcr.io/`
prefix. Its default is `<repository-owner>/<repository-name>-release-poc`, separate
from the existing deployment image. Publication verification requires public package
visibility. If GHCR creates the package privately on its first push, make that package
public and rerun the failed publication job with its original artifacts. Only publication
jobs receive write permissions.

The server image uses the public build configuration described in
[Deployment](DEPLOYMENT.md). Public Supabase and auth values remain baked into this
POC image; runtime values must match. A generic image configurable for any Supabase
instance requires separate application work. Backend secrets must never be build inputs.

## Owner acceptance and recovery

Validate installation, launch, version metadata, signatures/notarization and uninstall
on every advertised desktop target. Use an isolated candidate server to check session
restoration, sign-in/out, parcel navigation, challenge handling and connection recovery.
Validate each OCI architecture with an isolated backend; the pipeline's synthetic
process/browser checks do not establish database readiness or real-provider behavior.

Check unchanged-source skipping, failed runs, conflicting versions and retries before
enabling publication. A complete required matrix is assembled before a GitHub Release
is published. The image and release manifest are bound by digest and checksums.
GitHub Releases and GHCR do not offer a shared atomic transaction: candidate image
content can exist before the release, while channel aliases can require repair afterward.

Retry publication with the original staged artifacts. Do not replace assets or tags to
make a failed retry pass. Different rebuilt bytes require a new version/run. Preserve the
failed run when diagnosing a conflict. Database upgrades and production rollout remain
separate operations following [Deployment](DEPLOYMENT.md).
