# 🐸 Setup JFrog CLI (Access Token)

A composite GitHub Action that installs **JFrog CLI** and authenticates it with a long-lived or CI-scoped *access token*.
Optionally configures Maven to resolve dependencies from the specified Artifactory repositories.

---

## ✨ Features

* **One-shot login** – `jfrog setup-jfrog-cli@v4` plus token injection.
* **Maven‐ready** – Generates a `.m2/settings.xml` that points `releases` and `snapshots` to Artifactory.
* **Bolt-on** – Designed to be called right before any build; no persistent state.
* **Air-gapped-friendly** – Works with a mirrored Artifactory instance (see [Source 5]()).

---

## 🚀 Usage

```yaml
name: Build & Upload

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      # 1️⃣  JDK is required because we invoke Maven later
      - name: Set up JDK
        uses: your-org/setup-jdk@v1
        with:
          java-version: 17

      # 2️⃣  Authenticate to Artifactory + configure Maven
      - name: Set up JFrog CLI
        uses: your-org/setup-jfrog-cli-token@v1
        with:
          jf-url: ${{ vars.JF_URL }}
          jf-access-token: ${{ secrets.JF_ACCESS_TOKEN }}
          jf-repo-resolve-releases: libs-release               # optional
          jf-repo-resolve-snapshots: libs-snapshot             # optional

      # 3️⃣  Example build that consumes the configuration
      - name: Build with Maven
        run: mvn -B verify

      # 4️⃣  Optional: use JFrog CLI commands
      - name: Ping Artifactory
        run: jfrog rt ping
```

---

## 🔡 Inputs

| Name                        | Description                                                    | Required | Default         |
| --------------------------- | -------------------------------------------------------------- | -------- | --------------- |
| `jf-url`                    | Base URL of your JFrog platform (e.g. `https://acme.jfrog.io`) | **Yes**  | —               |
| `jf-access-token`           | JFrog *Access Token* with API scope                            | **Yes**  | —               |
| `jf-repo-resolve-releases`  | Repository key for **release** artifacts                       | No       | `libs-release`  |
| `jf-repo-resolve-snapshots` | Repository key for **snapshot** artifacts                      | No       | `libs-snapshot` |

---

## 📤 Outputs

This action emits **no** outputs.

---

## ⚙️ Configuration Notes

1. **JDK prerequisite**
   Maven needs a Java runtime; install it first (see example).

2. **Environment variables**
   `setup-jfrog-cli@v4` reads `JF_URL` and `JF_ACCESS_TOKEN`.
   These are supplied via `env` in the composite action’s first step.

3. **Custom build tools**
   If you build with Gradle, sbt, or npm, simply ignore the Maven step or fork the action to add your own CLI configuration command.

4. **Self-hosted / air-gapped runners**
   Mirror the [JFrog releases registry]() inside your network and set `JFROG_CLI_OFFER_CONFIG=false` to avoid outbound calls.

---

## 💻 Development

* **Tech stack:** YAML + Bash only (composite action).
* **Tests:** Use [`act`](https://github.com/nektos/act) with a dummy workflow.
* **Versioning:** Semantic tags (`v1`, `v1.1.0`, …) so consumers can pin.

---

## 📋 Prerequisites

| Requirement                                | Why it matters                                      |
| ------------------------------------------ | --------------------------------------------------- |
| Runner with Internet or Artifactory mirror | Downloads JFrog CLI & communicates with Artifactory |
| JDK installed (if Maven is used)           | Required for `mvn` commands                         |
| ≈ 300 MB free disk space                   | Stores the JFrog CLI binary & Maven cache           |

---

## 📚 Sources

1. [JFrog CLI Documentation](https://jfrog.com/help/r/jfrog-security-user-guide/developers/cli)
2. [Setup JFrog CLI GitHub Action](https://github.com/marketplace/actions/setup-jfrog-cli)
3. [JFrog CLI Authentication Methods](https://github.com/marketplace/actions/setup-jfrog-cli#Authentication-Methods)
4. [Shifting Left on Security with JFrog](https://jfrog.com/help/r/jfrog-security-user-guide/shift-left-on-security)
5. [Working in Air-Gapped Environments with JFrog](https://jfrog.com/help/r/jfrog-security-user-guide/shift-left-on-security/working-in-air-gapped-environments)

