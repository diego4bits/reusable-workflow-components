# 📦 Upload JAR & POM to JFrog

A composite GitHub Action that uploads a **JAR** and its corresponding **POM** file to JFrog Artifactory using JFrog CLI, authenticated via an application access token.

---

## ✨ Features

* **Artifact validation** – Ensures the JAR and POM files exist before uploading.
* **Direct upload** – Uses JFrog CLI for secure artifact upload.
* **Air-gapped support** – Compatible with internally mirrored JFrog instances.

---

## 🚀 Usage

```yaml
name: Upload JAR & POM

on: [push]

jobs:
  upload:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      # Example artifact generation step
      - name: Generate JAR and POM
        run: |
          ./mvnw clean package

      - name: Set up JFrog CLI
        uses: your-org/setup-jfrog-cli-token@v1
        with:
          jf-url: ${{ vars.JF_URL }}
          jf-access-token: ${{ secrets.JF_ACCESS_TOKEN }}

      - name: Upload artifacts to JFrog
        uses: your-org/upload-jar-pom-jfrog@v1
        with:
          jar-path: ./target/example.jar
          pom-path: ./target/pom.xml
          jf-upload-repo-path: your-repo-path
```

---

## 🔡 Inputs

| Name                  | Description                          | Required | Default |
| --------------------- | ------------------------------------ | -------- | ------- |
| `jar-path`            | Absolute path to the JAR file        | **Yes**  | —       |
| `pom-path`            | Absolute path to the POM file        | **Yes**  | —       |
| `jf-upload-repo-path` | Repository path in JFrog Artifactory | **Yes**  | —       |

---

## 📤 Outputs

This action emits **no** outputs.

---

## ⚙️ Configuration Notes

1. **Artifact validation**
   Validates that both JAR and POM files exist prior to upload.

2. **Environment setup**
   Ensure JFrog CLI is previously set up with proper authentication and configuration using the "Setup JFrog CLI" action in the same job.

3. **Air-gapped environments**
   Compatible with environments using a mirrored JFrog instance; ensure proper internal network configuration.

---

## 💻 Development

* **Tech stack:** YAML + Bash (composite action).
* **Tests:** Local testing using [`act`](https://github.com/nektos/act).
* **Versioning:** Semantic tags (`v1`, `v1.0.0`, …) for pinned usage.

---

## 📋 Prerequisites

| Requirement                                | Why it matters                                      |
| ------------------------------------------ | --------------------------------------------------- |
| Runner with Internet or Artifactory mirror | Downloads JFrog CLI & communicates with Artifactory |
| JFrog CLI setup                            | Required for artifact upload commands               |
| Setup JFrog CLI action                     | Must run in the same job for authentication         |
| ≈ 300 MB free disk space                   | Stores JFrog CLI binary and temporary files         |

---

## 📚 Sources

1. [JFrog CLI Documentation](https://jfrog.com/help/r/jfrog-security-user-guide/developers/cli)
2. [Setup JFrog CLI GitHub Action](https://github.com/marketplace/actions/setup-jfrog-cli)
3. [JFrog CLI Authentication Methods](https://github.com/marketplace/actions/setup-jfrog-cli#Authentication-Methods)
4. [Working in Air-Gapped Environments with JFrog](https://jfrog.com/help/r/jfrog-security-user-guide/shift-left-on-security/working-in-air-gapped-environments)
5. [Shift Left on Security with JFrog](https://jfrog.com/help/r/jfrog-security-user-guide/shift-left-on-security)
