# 🔍 SonarQube Scan

A composite GitHub Action that performs a **SonarQube scan** on your project using the official SonarQube Scan Action. It generates a `sonar-project.properties` file with provided inputs and ensures comprehensive static code analysis.

---

## ✨ Features

* **Automated configuration** – Generates `sonar-project.properties` file automatically.
* **Flexible customization** – Configurable source, test, binary directories, and encoding.
* **Official integration** – Uses the SonarQube official GitHub Action for consistency.
* **Secure authentication** – Uses provided SonarQube token securely.

---

## 🚀 Usage

```yaml
name: SonarQube Scan

on: [push]

jobs:
  scan:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: SonarQube Scan
        uses: your-org/sonarqube-scan@v1
        with:
          sonar-host-url: ${{ secrets.SONAR_HOST_URL }}
          sonar-token: ${{ secrets.SONAR_TOKEN }}
          sonar-organization: your-organization
          sonar-project-key: your-project-key
          sonar-project-name: your-project-name
```

---

## 🔡 Inputs

| Name                   | Description                    | Required | Default         |
| ---------------------- | ------------------------------ | -------- | --------------- |
| `sonar-host-url`       | SonarQube server URL           | **Yes**  | —               |
| `sonar-token`          | SonarQube authentication token | **Yes**  | —               |
| `sonar-organization`   | SonarQube organization         | **Yes**  | —               |
| `sonar-project-key`    | SonarQube project key          | **Yes**  | —               |
| `sonar-project-name`   | SonarQube project name         | **Yes**  | —               |
| `sonar-sources`        | Source directories             | No       | `src/main/java` |
| `sonar-tests`          | Test directories               | No       | `src/test/java` |
| `sonar-binaries`       | Binary directories             | No       | `target/`       |
| `sonar-sourceEncoding` | Source file encoding           | No       | `UTF-8`         |

---

## 📤 Outputs

This action emits **no** explicit outputs, but the SonarQube analysis results are available on your SonarQube server.

---

## ⚙️ Configuration Notes

1. **Generated Properties**
   Creates a `sonar-project.properties` file at the root of your repository, customized using provided inputs.

2. **Official Action Usage**
   Utilizes the official [SonarQube Scan Action](https://github.com/SonarSource/sonarqube-scan-action) for reliability.

---

## 📂 Example Configuration

```yaml
steps:
  - name: Checkout repository
    uses: actions/checkout@v4

  - name: SonarQube Scan
    uses: your-org/sonarqube-scan@v1
    with:
      sonar-host-url: ${{ secrets.SONAR_HOST_URL }}
      sonar-token: ${{ secrets.SONAR_TOKEN }}
      sonar-organization: my-org
      sonar-project-key: my-project-key
      sonar-project-name: my-project-name
      sonar-sources: src/
      sonar-tests: tests/
      sonar-binaries: build/classes
      sonar-sourceEncoding: UTF-8
```

Results are available directly on your SonarQube server.

---

## 💻 Development

* **Tech stack:** YAML + Bash (composite action).
* **Testing:** Local testing with [`act`](https://github.com/nektos/act).
* **Versioning:** Semantic tags (`v1`, `v1.0.0`, …) to pin versions.

---

## 📋 Prerequisites

| Requirement                       | Why it matters                           |
| --------------------------------- | ---------------------------------------- |
| Runner with Internet access       | Communicates with SonarQube server       |
| SonarQube server credentials      | Required for authentication and analysis |
| Java Runtime (JDK 17 recommended) | Required for SonarQube scan analysis     |
| ≈ 500 MB free disk space          | Stores dependencies and temporary files  |

---

## 📚 Sources

1. [SonarQube Scan Action](https://github.com/SonarSource/sonarqube-scan-action)
2. [SonarQube Documentation](https://docs.sonarqube.org/latest/)
3. [GitHub Actions Documentation](https://docs.github.com/en/actions)
