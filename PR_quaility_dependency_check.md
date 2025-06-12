## 📄 **Title**

**feat(ci): Add OWASP Dependency-Check and SonarQube Static Analysis GitHub Actions**

---

## 1. **Summary**

This PR introduces two GitHub Actions aimed at enhancing the static analysis and quality checks of our codebase:

* **OWASP Dependency-Check** – Scans project dependencies for known vulnerabilities.
* **SonarQube Scan** – Conducts comprehensive static code analysis, reporting on code quality, bugs, vulnerabilities, and maintainability.

---

## 2. **Motivation**

* **Security enhancement**: Proactively identify and mitigate security vulnerabilities in dependencies.
* **Code Quality Improvement**: Ensure continuous monitoring and enhancement of the code quality through static analysis.
* **Compliance**: Meet compliance requirements for vulnerability scanning and code quality standards.
* **Automation & consistency**: Provide standardized, reusable CI/CD actions for all repositories.

---

## 3. **Changes**

### 🛡️ **OWASP Dependency-Check**

* Runs OWASP Dependency-Check in its official container.
* Generates detailed reports (HTML, JSON, XML) on vulnerabilities.
* Provides flexible configuration options via direct arguments.
* Outputs generated reports directly in GitHub workspace.

### 🔍 **SonarQube Scan**

* Automatically creates `sonar-project.properties` with provided parameters.
* Integrates with the official SonarQube GitHub Action for consistent static analysis.
* Customizable inputs for source, test, and binaries directories and source encoding.
* Secure authentication to SonarQube server via provided tokens.

---

## 4. **Testing & Verification**

* **Local Validation**:

  * Both actions extensively tested locally using [`act`](https://github.com/nektos/act).
  * Verified correct generation of `sonar-project.properties`.
  * Confirmed accurate vulnerability reports from OWASP Dependency-Check.
* **Workflow Integration**:

  * Successfully integrated into existing workflows, validating end-to-end execution.

---

## 5. **Dependencies & Preconditions**

* OWASP Dependency-Check requires a Docker-enabled runner.
* SonarQube Scan requires:

  * Java 17 runtime.
  * Valid SonarQube server credentials and tokens.

---

## 6. **Rollout Plan & Backwards Compatibility**

* No breaking changes introduced.
* Adoption is incremental; actions versioned (`v1`, `v1.x.x`) for easy pinning.

---

## 7. **Notes for Reviewers**

* Verify accuracy and clarity of documentation (`README.md`) for both actions.
* Ensure flexible input configurations meet typical usage scenarios.
* Review YAML and Bash scripts for correctness, security best practices, and efficiency.

---

### ✅ **Next Steps**

Upon approval, the next step is to tag stable releases (`v1.0.0`) and incorporate these actions into standard CI/CD templates.
Please share any additional feedback or requests for improvement!
