# 🚀 Build & Test Using Maven & JFrog

A composite GitHub Action that builds and tests a Java project using **Maven**, resolving dependencies from a JFrog repository. It outputs the paths of the generated JAR and POM files for subsequent actions.

---

## ✨ Features

* **Maven & JFrog Integration** – Resolves dependencies directly from a configured JFrog repository.
* **Automated Testing** – Runs project tests during the build.
* **Artifact Outputs** – Provides absolute paths to the JAR and POM for easy access by other workflow steps.

---

## 🚀 Usage

```yaml
name: Build & Test

on: [push]

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK
        uses: your-org/setup-jdk@v1
        with:
          java-distribution: temurin
          java-version: 17

      - name: Set up JFrog CLI
        uses: your-org/setup-jfrog-cli-token@v1
        with:
          jf-url: ${{ vars.JF_URL }}
          jf-access-token: ${{ secrets.JF_ACCESS_TOKEN }}

      - name: Build & Test using Maven & JFrog
        uses: your-org/build-test-maven-jfrog@v1

      - name: Upload artifacts to JFrog
        uses: your-org/upload-jar-pom-jfrog@v1
        with:
          jar-path: ${{ steps.build-test.outputs.jar-path }}
          pom-path: ${{ steps.build-test.outputs.pom-path }}
          jf-upload-repo-path: your-repo-path
```

---

## 📤 Outputs

| Output     | Description                                 |
| ---------- | ------------------------------------------- |
| `jar-path` | Absolute path to the generated JAR file     |
| `pom-path` | Absolute path to the project's pom.xml file |

---

## ⚙️ Configuration Notes

1. **Prerequisites**
   This action requires prior execution of:

   * **Setup JDK** action to provide the Java runtime.
   * **Setup JFrog CLI** action for dependency resolution via JFrog Artifactory.

2. **Artifact Handling**
   Generates JAR and POM files automatically as outputs for seamless use in later workflow steps.

---

## 💻 Development

* **Tech stack:** YAML + Bash (composite action).
* **Testing:** Local testing with [`act`](https://github.com/nektos/act).
* **Versioning:** Semantic tags (`v1`, `v1.0.0`, …) to pin versions.

---

## 📋 Prerequisites

| Requirement                                | Why it matters                                       |
| ------------------------------------------ | ---------------------------------------------------- |
| Runner with Internet or Artifactory mirror | Resolves Maven dependencies via JFrog                |
| JDK installed                              | Required for Maven build and tests                   |
| JFrog CLI configured                       | Necessary for dependency resolution from Artifactory |
| ≈ 500 MB free disk space                   | Stores JFrog CLI binaries, dependencies, and builds  |

---

## 📚 Sources

1. [JFrog CLI Documentation](https://jfrog.com/help/r/jfrog-security-user-guide/developers/cli)
2. [Setup JFrog CLI GitHub Action](https://github.com/marketplace/actions/setup-jfrog-cli)
3. [Maven Documentation](https://maven.apache.org/)
4. [actions/setup-java Documentation](https://github.com/actions/setup-java)
5. [GitHub Actions Guide](https://docs.github.com/en/actions)
