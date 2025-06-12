# ☕️ Setup JDK

A tiny composite GitHub Action that installs and configures JDK 17 (or any other distribution/version supported by `actions/setup-java`) so your workflow can build, test, and package Java applications.

---

## 🧩 Features

- **Zero-config defaults** – Temurin 17 out of the box.  
- **Full control** – Override `distribution` and `java-version` for any JDK you need.  
- **Cross-platform** – Works on Ubuntu, macOS, and Windows runners.  
- **Cache-friendly** – Leverages the built-in dependency cache of `actions/setup-java@v4`.

---

## 🔧 Usage

```yaml
# .github/workflows/ci.yml
jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK
        uses: your-org/setup-jdk@v1   # ← replace with actual ref
        with:
          java-distribution: temurin   # optional
          java-version: 21             # optional
          
      - name: Build
        run: ./mvnw -B verify
````

---

## 🔡 Inputs

| Name                | Description                                          | Required | Default   |
| ------------------- | ---------------------------------------------------- | -------- | --------- |
| `java-distribution` | JDK distribution (`temurin`, `zulu`, `microsoft`, …) | No       | `temurin` |
| `java-version`      | Major version (e.g., `8`, `11`, `17`, `21`)          | No       | `17`      |

---

## 📤 Outputs

This action does **not** emit explicit outputs.

---

## ⚙️ Configuration

1. **Caching** – `actions/setup-java@v4` can cache Maven, Gradle, or sbt dependencies when `cache` is set:

   ```yaml
   with:
     java-version: 17
     distribution: temurin
     cache: maven
   ```

2. **Matrix builds** – Combine with a build matrix to test multiple JDKs:

   ```yaml
   strategy:
     matrix:
       java: [11, 17, 21]
   steps:
     - uses: your-org/setup-jdk@v1
       with:
         java-version: ${{ matrix.java }}
   ```

3. **Permissions** – No special permissions are required beyond the default `contents: read`.

---

## 💻 Development

* **Language:** YAML + Bash only (composite action).
* **Test locally:** Use [`act`](https://github.com/nektos/act) with a sample workflow.
* **Release:** Tag the commit (`v1`, `v1.0.1`, …) so users can pin versions.

---

## 📋 Prerequisites

| Requirement                 | Why it matters        |
| --------------------------- | --------------------- |
| Runner with Internet access | Downloads the JDK     |
| ≈ 500 MB free disk space    | Stores the JDK binary |

---

## 📚 Sources

1. [actions/setup-java Documentation](https://github.com/actions/setup-java)
2. [Temurin JDK Distributions](https://adoptium.net/)
3. [GitHub Actions Guide](https://docs.github.com/en/actions)



