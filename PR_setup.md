## 📄 Title

**chore(ci): integrate Java build actions – Setup JDK, Setup JFrog CLI, Build & Upload artifacts**

---

## 1. Summary

This PR introduces a set of composable GitHub Actions tailored for Java projects:

1. **Setup JDK** – installs and configures Java (default Temurin 17, configurable).
2. **Setup JFrog CLI** – installs JFrog CLI and authenticates via an access token.
3. **Build & Test Using Maven & JFrog** – runs `jfrog mvn clean install -B`, outputs paths to `jar` and `pom`.
4. **Upload JAR & POM to JFrog** – validates artifact presence and performs upload to Artifactory.

The combined effect is an end‑to‑end CI pipeline: compile, test, resolve dependencies via JFrog, and publish artifacts.

---

## 2. Motivation

* **Reusability**: Standardizes Java setup and artifact handling across repositories.
* **Separation of concerns**: Each step is encapsulated in its own Action.
* **Flexibility**: Compose steps as needed; e.g., use only build/test without upload.
* **Security & consistency**: Enforces authentication via JFrog CLI and ensures artifacts are generated before upload.

---

## 3. Changes

* Added **setup-jdk** Action supporting configurable Java versions with cache capability.
* Added **setup-jfrog-cli-token** Action to install JFrog CLI and set API token.
* Added **build-test-maven-jfrog** Action:

  * Requires prior execution of Setup JDK and Setup JFrog CLI in the same job.
  * Runs Maven build+tests via `jfrog mvn`.
  * Exposes `jar-path` and `pom-path` as outputs.
* Added **upload-jar-pom-jfrog** Action:

  * Validates artifact existence.
  * Uploads JAR and POM to a configured Artifactory repo.

Each Action includes a structured README with inputs/outputs, usage examples, development notes, and prerequisites.

---

## 4. Testing & Verification

* **Manual testing**: Verified end‑to‑end flow in a sample repository:

  1. Checkout
  2. Setup JDK
  3. Setup JFrog CLI
  4. Build & Test → outputs path as expected
  5. Upload → artifacts successfully appear in Artifactory
* **Unit testability**: Each composite action tested locally via `act`.
* **Adopted version control**: Tagged `v1.0.0` for stable usage.

---

## 5. Dependencies & Preconditions

These composite actions assume the `setup-jdk` and `setup-jfrog-cli` steps run **in the same job** as build/test/upload. This ensures:

* `JAVA_HOME` is correctly set for Maven.
* JFrog CLI is installed and authenticated.

---

## 6. Rollout Plan & Backwards Compatibility

* No changes to existing workflows until adoption is explicit.
* Default Java version (17) aligns with current standards.
* Semantic versioning (v1, v1.x.x) ensures users can safely pin versions.

---

## 7. Notes for Reviewers

* Check **README structure** for clarity, consistency, and typos.
* Verify **composite definitions** (`action.yml`) match documentation.
* Review **Javac/JFrog CLI execution** in build/test step for correct flags.
* Evaluate **error handling** (fails only on scanner/cli errors).

---

### ✅ Next Steps

Upon approval, I’ll tag all Actions as `v1.0.0` and update a sample repo’s CI to adopt this workflow. Let me know if any adjustments are needed!

---
