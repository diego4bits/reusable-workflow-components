# 🛡️ OWASP Dependency-Check

A GitHub Action that runs **OWASP Dependency-Check** inside the official container, scanning your project for known vulnerabilities and generating comprehensive reports. The action only fails if the scanner itself returns a non-zero exit code.

---

## ✨ Features

* **Official container** – Uses the OWASP Dependency-Check Docker image for reliability and consistency.
* **Flexible configuration** – Pass custom flags directly to Dependency-Check.
* **Detailed reports** – Generates HTML, JSON, or XML reports.
* **Environment-aware** – Report outputs are placed within the GitHub workspace.

---

## 🚀 Usage

```yaml
name: Dependency-Check

on: [push]

jobs:
  scan:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: OWASP Dependency-Check
        uses: your-org/owasp-dependency-check@v1
        with:
          scan-args: |
            --disableRetireJS
            --scan "**/*.jar"
            --format HTML
            --format JSON
            --format XML
```

---

## 🔡 Inputs

| Name        | Description                                        | Required | Default |
| ----------- | -------------------------------------------------- | -------- | ------- |
| `scan-args` | Arguments passed directly to `dependency-check.sh` | **Yes**  | —       |

---

## 📤 Outputs

| Output        | Description                                 |
| ------------- | ------------------------------------------- |
| `report-path` | Directory or file path of generated reports |

---

## ⚙️ Configuration Notes

1. **Report location**
   Reports are saved within the GitHub workspace (`${{ github.workspace }}`).

2. **Containerized execution**
   Runs Dependency-Check in the official Docker container, ensuring a consistent environment.

---

## 📂 Example Configuration

```yaml
steps:
  - name: Checkout repository
    uses: actions/checkout@v4

  - name: OWASP Dependency-Check
    uses: your-org/owasp-dependency-check@v1
    with:
      scan-args: |
        --disableRetireJS
        --scan "**/*.java"
        --format HTML
        --out ./reports
```

Generated reports can be found in the GitHub workspace (`${{ github.workspace }}/reports`).

---

## 💻 Development

* **Tech stack:** Docker, Bash, YAML.
* **Tests:** Local testing via Docker or [`act`](https://github.com/nektos/act).
* **Versioning:** Semantic tags (`v1`, `v1.0.0`, …) for stable usage.

---

## 📋 Prerequisites

| Requirement              | Why it matters                                |
| ------------------------ | --------------------------------------------- |
| Docker-enabled runner    | Runs Dependency-Check container               |
| ≈ 500 MB free disk space | Stores container images and generated reports |

---

## 📚 Sources

1. [OWASP Dependency-Check Documentation](https://jeremylong.github.io/DependencyCheck/)
2. [OWASP Dependency-Check Docker Image](https://hub.docker.com/r/owasp/dependency-check)
3. [GitHub Actions Documentation](https://docs.github.com/en/actions)
