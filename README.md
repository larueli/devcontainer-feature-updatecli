# Updatecli Dev Container Feature


![GitHub Release](https://img.shields.io/github/v/release/larueli/devcontainer-feature-updatecli?sort=semver&display_name=release)
[![test](https://github.com/larueli/devcontainer-feature-updatecli/actions/workflows/test.yml/badge.svg)](https://github.com/larueli/devcontainer-feature-updatecli/actions/workflows/test.yml)
[![dependabot](https://img.shields.io/badge/dependabot-enabled-025E8C?logo=dependabot&logoColor=white)](https://github.com/dependabot)


Installs [updatecli](https://github.com/updatecli/updatecli) in a dev container using GitHub releases and checksum verification.

## Options

| Option  | Type   | Default | Description                                                          |
|--------|--------|---------|----------------------------------------------------------------------|
| version | string | latest  | Updatecli version (e.g. `v0.81.0`). Use `latest` for the newest release. |

## Example usage

### Use latest Updatecli

```jsonc
{
  "features": {
    "ghcr.io/larueli/devcontainer-feature-updatecli/updatecli:1": {
      "version": "latest"
    }
  }
}
```

## Reference

* [Devcontainers features starter](https://github.com/devcontainers/feature-starter)
