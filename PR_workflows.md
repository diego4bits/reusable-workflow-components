## 1. **Summary**

This PR introduces two reusable GitHub Actions workflows designed specifically for Java library projects:

* **Regular Java Library Workflow**

  * Builds, tests, and scans code using Maven, OWASP Dependency-Check, and SonarQube.
  * Integrates with JFrog for dependency resolution and artifact management.
  * Automates semantic versioning via Semantic Release.

* **Tagged Version Java Library Workflow**

  * Triggered by tags, performs Maven build and test.
  * Handles artifact publication to JFrog Artifactory under a structured path reflecting the version tag.

---

## 2. **Motivation**

* **Standardization & Reusability**: Establishes a uniform approach to Java project CI/CD pipelines across repositories.
* **Automation & Quality Assurance**: Automates comprehensive static analysis, dependency scanning, and artifact management, ensuring high-quality, secure releases.
* **Version Control Integration**: Supports tagged releases and automated semantic versioning to streamline release processes.

---

## 3. **Changes**

### 🔄 **Regular Java Library Workflow**

* Performs Maven build and tests, resolves dependencies via JFrog.
* Executes OWASP Dependency-Check to identify vulnerabilities in dependencies.
* Runs SonarQube static code analysis for code quality assurance.
* Automates version management using Semantic Release for consistent, reliable release processes.

### 🏷️ **Tagged Version Java Library Workflow**

* Triggered explicitly by tags (e.g., for production releases).
* Resolves dependencies via JFrog, builds and tests using Maven.
* Uploads the final artifacts (JAR and POM) to JFrog Artifactory in a structured path reflecting the release tag.

---

## 4. **Testing & Verification**

* Verified end-to-end workflows in sandbox environments:

  * Correct artifact generation and uploads to JFrog Artifactory.
  * Accurate execution of SonarQube and Dependency-Check reports.
  * Successful automated semantic releases.
* Local testing conducted using `act` to validate workflow execution and configuration correctness.

---

## 5. **Dependencies & Preconditions**

These workflows assume prior configuration of the following:

* JFrog Artifactory credentials and repository configurations.
* SonarQube instance setup with required authentication tokens.
* Semantic Release bot configured with proper GitHub token permissions.
* OWASP Dependency-Check availability (Docker-enabled runners).

---

## 6. **Rollout Plan & Backwards Compatibility**

* Workflows introduced as reusable components; no breaking changes.
* Adoption is incremental and explicit, ensuring current setups remain unaffected.
* Clearly documented and versioned to allow easy, safe adoption.

---

## 7. **Notes for Reviewers**

* Validate workflow YAML configurations for accuracy, readability, and consistency.
* Ensure documentation clearly captures inputs, outputs, secrets, and intended usage patterns.
* Confirm proper error handling and robustness of each step in both workflows.


