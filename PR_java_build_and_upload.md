## 📄 **Title**

**feat(ci): Add GitHub Actions for Maven Build/Test and Artifact Upload to JFrog**

---

## 1. **Summary**

This PR introduces two composite GitHub Actions to automate Java project build, test, and artifact management:

* **Build & Test Using Maven & JFrog**: Builds the project, resolves dependencies from JFrog Artifactory, runs tests, and outputs artifact paths.
* **Upload JAR & POM to JFrog**: Validates the existence of generated artifacts (JAR and POM) and uploads them securely to JFrog Artifactory.

Together, these actions provide a seamless Java CI/CD pipeline—from compilation and testing to artifact publishing.

---

## 2. **Motivation**

* **Automated Workflow**: Streamlines build, test, and artifact management processes into composable GitHub Actions.
* **Consistency and Reliability**: Standardizes artifact management and dependency resolution across multiple repositories.
* **Flexibility**: Actions can be used independently or combined for full CI/CD integration.
* **Security and Validation**: Ensures artifacts exist before upload, reducing potential build issues and deployment errors.

---

## 3. **Changes**

### **🚀 Build & Test Using Maven & JFrog**

* Executes Maven build and tests via `jfrog mvn clean install -B`.
* Resolves dependencies directly from a configured JFrog repository.
* Outputs absolute paths for generated artifacts (`jar-path` and `pom-path`) for subsequent steps.

### **📦 Upload JAR & POM to JFrog**

* Validates presence of JAR and POM files before uploading.
* Uploads artifacts securely to the specified JFrog Artifactory repository.
* Compatible with air-gapped setups using internal Artifactory mirrors.

---

## 4. **Testing & Verification**

* **Local Testing**: Verified locally with `act`, ensuring:

  * Artifacts generated and validated correctly.
  * JFrog CLI interactions (dependency resolution and upload) succeed.
* **End-to-End Workflow**: Successfully tested in a real-world scenario, confirming seamless integration and artifact publication to JFrog Artifactory.

---

## 5. **Dependencies & Preconditions**

Ensure the following actions are executed **before** using these actions within the same job:

* **Setup JDK** – to provide Java runtime required by Maven.
* **Setup JFrog CLI** – for authentication and dependency management with Artifactory.

---

## 6. **Rollout Plan & Backwards Compatibility**

* No breaking changes introduced; existing workflows unaffected until explicitly adopted.
* Actions versioned with semantic tags (`v1`, `v1.x.x`) to allow safe pinning.

---

## 7. **Notes for Reviewers**

* Please ensure that documentation (`README.md`) clearly reflects input/output specifications.
* Validate that artifact path outputs (`jar-path`, `pom-path`) function correctly in subsequent workflow steps.
* Review bash scripts and YAML action files for clarity and correctness.

---

### ✅ **Next Steps**

Upon approval, stable versions (`v1.0.0`) will be tagged, and documentation updated accordingly. Feedback and suggestions are very welcome!
