# Release Guidelines

This guide intends to outline process to release a new versions of tvk-plugins.

## Steps:

1. Set Release Tag:

    Follow [semantic versioning](https://semver.org/spec/v2.0.0.html). Release tags versions should start with `v`. Ex. v1.0.0
    ```
    TAG=v1.0.0
    ```

2. Create Release branch:

    Follow branch naming convention like `release/vx.x.x`
    ```
    git checkout -b release/$TAG origin/main
    ```
   
3.  Tag the Release:

     ```
     git checkout release/$TAG
     git tag -a "${TAG:?TAG required}"
     ```
4. Push the release branch & tag:

     ```
     git push origin release/$TAG
     git push origin "${TAG:?TAG required}"
     ```   
5. Wait until the github actions workflow `Plugin Packages CI` succeeds.

6. Verify on Releases tab on GitHub. Make sure plugin's tarball and sha256 release assets show up on `Releases` tab and
   `Releases` is marked as `pre-release`(not ready for production).
   
7. Perform QA on release packages using testing methods mentioned in [`CONTRIBUTION.md`](./docs/CONTRIBUTION.md).

8. Once release build is verified, update plugin manifests using methods mentioned in [`CONTRIBUTION.md`](./docs/CONTRIBUTION.md)
   and create PR for the same.
   
9. Wait for github actions workflow `Plugin Manifests CI` to succeeds for newly created PR containing plugin manifest changes, merge PR
   once workflows succeeds.

10. From Github `Releases` tab, update Release's CHANGELOG and uncheck `pre-release` and update release.

11. Now, Release is ready for production and will be marked as latest release for github.
