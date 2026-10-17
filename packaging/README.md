# SoapyPlutoSDR, packaged for Debian (welland)

This is [mithro/apt-repo-action](https://github.com/mithro/apt-repo-action)'s
**Set A** layout (`docs/packaging.md`): a GitHub fork of
[pothosware/SoapyPlutoSDR](https://github.com/pothosware/SoapyPlutoSDR) with

- `upstream`: an unmodified copy of upstream's `master`, only ever
  fast-forwarded;
- `packaging` (the default branch): `upstream` plus `debian/`, `packaging/`
  and `.github/` (`apt-packaging.toml` and our workflows).

Nothing here is sent upstream without Tim's explicit approval.

## What is built

Upstream's **git `master`**, not a release. SoapyPlutoSDR is the SoapySDR
module for ADALM-PLUTO and the radios that run Pluto-compatible firmware,
such as the MicroPhase ANTSDR E310. OpenWebRX's `pluto_sdr` device type needs
it. Debian packages it in forky and sid (0.2.2-1.1), but not in trixie, the
suite the welland Raspberry Pis run. `master` also has what 0.2.2 doesn't,
including the automatic RX buffer sizing for high sample rates over gigabit
Ethernet.

## Where `debian/` comes from

Debian's packaging, from
[salsa.debian.org/debian-hamradio-team/soapysdr/soapyplutosdr](https://salsa.debian.org/debian-hamradio-team/soapysdr/soapyplutosdr)
at `d0efce3` (0.2.2-1), imported unchanged with its changelog history, in
place of upstream's own `debian/` (which builds `soapysdr0.9-module-plutosdr`,
for a libsoapysdr0.9 no Debian suite has). Then, in separate commits:

- Debian's 0.2.2-1.1 changelog entry, from the archive (the non-maintainer
  upload isn't on salsa). Its one quilt patch is upstream's `4a01ddf`, which
  `master` already has, so it isn't carried;
- our `Maintainer:` and `Vcs-*`; Debian's maintainer is kept as
  `XSBC-Original-Maintainer:`.

The package names are Debian's (`soapysdr0.8-module-plutosdr`,
`soapysdr-module-plutosdr`), so this build and Debian's replace each other on
upgrade.

## Our changes to upstream's code

None. See `git log upstream..packaging -- ':!debian' ':!packaging' ':!.github'`.

## Version

apt-repo-action's shared `scripts/deb-version.py` makes it
(`docs/packaging.md`, "Set A"), from `version-args` in
`.github/workflows/deb.yml`:

    <release>+git<N>.g<sha7>-0+welland<M>[~deb<R>][~pr<P>]

`<release>` is upstream's last release tag (`soapy-plutosdr-0.2.3` → `0.2.3`),
`N` the upstream commits since it, `sha7` the upstream commit built (the
merge base of the build and `upstream`), and `M` the commits on `packaging`
that aren't on `upstream`. `~deb<R>` is the suite's Debian release (sid has
none) and `~pr<P>` a pull request's preview. For example
`0.2.3+git2.g01ee438-0+welland9~deb13`: above Debian's 0.2.2-1.1, below a
Debian 0.2.4-1 (which is the signal to merge upstream).

## Updating to a new upstream

`Sync upstream` (`.github/workflows/sync-upstream.yml`) runs weekly: it
fast-forwards `upstream` and opens the pull request "Merge upstream <sha>"
into `packaging`. Merge it with a merge commit, never a rebase.

The sync runs with the workflow's own token: the repository has no
`SYNC_TOKEN`, on purpose. Pushes and pull requests made with that token start
no workflows, so upstream's code never runs here until a person starts it,
and a sync whose upstream commits change `.github/workflows/` is refused
rather than pushed. Do that one by hand:

```sh
git fetch https://github.com/pothosware/SoapyPlutoSDR.git master
git push origin FETCH_HEAD:refs/heads/upstream
git checkout -b sync/upstream origin/packaging
git merge --no-ff origin/upstream
```

Read what upstream changed under `.github/workflows/` before pushing the
merge: a pull request from a branch of this repository runs its workflows
with this repository's secrets.

## Install

```sh
sudo install -d -m0755 /etc/apt/keyrings
curl -fsSL https://mith.ro/SoapyPlutoSDR/SoapyPlutoSDR.gpg | sudo tee /etc/apt/keyrings/SoapyPlutoSDR.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/SoapyPlutoSDR.gpg] https://mith.ro/SoapyPlutoSDR/trixie/ ./" \
  | sudo tee /etc/apt/sources.list.d/SoapyPlutoSDR.list
sudo apt update
```

Put your suite in place of `trixie`: `trixie`, `forky`, `sid`,
`raspbian-trixie` or `raspbian-forky`.

The repository's signing key fingerprint is
`4773 9ADA FDDC 8DDA E4B9  18A8 4C0A 050D ABD9 114D`.
