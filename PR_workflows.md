
# Integrating Sonatype Nexus Lifecycle with GitHub Actions (Self-Hosted Runner)

## 1. Required Sonatype Tools

To integrate Nexus Lifecycle into your CI pipeline, you need Sonatype’s **Nexus Lifecycle (IQ Server)** and the **Sonatype IQ CLI** tool. Nexus Lifecycle (enterprise edition) provides the IQ Server which hosts your policies, application definitions, and reports. The Sonatype IQ CLI is a client (available as a JAR or Docker image) that scans your application or its artifacts and communicates with the IQ Server for policy evaluation. In practice, you can either call the IQ CLI directly (e.g. via `java -jar nexus-iq-cli.jar`) or use Sonatype’s official GitHub Action (which internally sets up and invokes the CLI). The GitHub Action (`sonatype/actions/evaluate`) conveniently bundles the CLI execution steps for you. Ensure that the IQ Server is set up and accessible to the self-hosted runner, and that you have the **Application ID** of the project defined in IQ Server (or plan to use automatic application creation) for the scans.

**Tools Summary:** Sonatype Nexus Lifecycle IQ Server (with an active license), Sonatype IQ CLI (or the Sonatype GitHub Action which uses it), and the language build tools for your project (e.g. Maven/Gradle for Java, npm for Node, etc., to produce the artifacts/lockfiles needed for scanning).

## 2. Authentication and Secret Management

**Authentication to IQ Server:** The IQ CLI requires credentials with permission to evaluate applications on the IQ Server. It’s recommended to use a **User Token** (a generated two-part token) instead of a raw username/password for CI service accounts. A user token consists of a user code and a passcode that act as username/password – this avoids exposing your actual login and can be easily revoked if needed. Whichever method you choose (user token or service account credentials), assign only the necessary privileges (the _Application Evaluator_ role or at least “Evaluate Applications” permission on the app/organization).

**Storing Secrets in GitHub:** Store the IQ Server URL, the token (or username), and the password/secret part of the token as **GitHub Actions Secrets**. For example, you might have `SONATYPE_LIFECYCLE_URL`, `SONATYPE_LIFECYCLE_USERNAME` (or user token code), and `SONATYPE_LIFECYCLE_PASSWORD` (or user token passcode) defined at the repository or organization level. GitHub encrypts secrets at rest and makes them available to workflows as environment variables, which you reference as `${{ secrets.SECRET_NAME }}` at runtime. Avoid printing these values, as GitHub will mask them in logs for security.

**Using HashiCorp Vault:** In high-security environments, you can retrieve credentials from HashiCorp Vault at runtime instead of storing them in GitHub. This can be done with the HashiCorp Vault Action. For example, you might add a step using `hashicorp/vault-action@v2` to authenticate to your Vault server (via a GitHub OIDC token or a Vault AppRole secret stored in GitHub) and fetch secrets, exporting them as environment variables for subsequent steps. In the Vault action configuration, you specify the Vault address and the secrets (paths and keys) to retrieve; these will populate environment variables (e.g. `SONATYPE_LIFECYCLE_PASSWORD`) that the IQ CLI step can use. This approach keeps sensitive tokens out of GitHub’s storage entirely, but requires your self-hosted runner to have network access to Vault.


## 3. Licensing and Account Requirements

Using Sonatype Nexus Lifecycle in CI/CD requires the appropriate enterprise licensing. **Sonatype Nexus Lifecycle** (IQ Server) is a commercial product – your organization must have a valid license installed on the IQ Server to perform policy evaluations in pipelines. Integrations (like the CLI or GitHub Action) are fully supported for licensed Nexus Lifecycle customers. Ensure your IQ Server license covers the applications you plan to scan and is up-to-date.

On the GitHub side, if you plan to surface Sonatype scan results in GitHub’s security features (code scanning alerts), you will need **GitHub Advanced Security**. The Sonatype GitHub Action can upload results as SARIF to GitHub code scanning, which is available on GitHub Enterprise (or public repositories) as part of Advanced Security. In a GitHub Enterprise Cloud or Server environment with Advanced Security enabled, you can integrate Sonatype scans so that policy violations appear on the repository’s “Security” tab. (If you don’t have Advanced Security, you can still run scans in GitHub Actions and use logs or artifacts, but you won’t get the native security tab integration.)

**Note on Accounts:** It’s best practice to use a dedicated service account in Sonatype IQ for CI integrations. This account (or its user token) should have the minimum roles needed (often “Automation” or “CI” roles) to evaluate policies. Also verify that your Sonatype license allows automated scans; generally there isn’t a limit on scan count, but some licenses limit the number of applications or developers. GitHub Actions itself (enterprise tier) should have no issue running on self-hosted runners as long as the runners are properly registered.

## 4. Artifact Upload and Policy Evaluation Process

**Preparing Artifacts for Scan:** After your code is built (compiled, dependencies resolved), you need to **upload or point the Sonatype scanner to your build output** so it can evaluate open-source components. Sonatype’s recommended approach is to scan the **post-build artifact or output directory**, because it contains all the resolved dependencies (direct and transitive) that your application will ship with. For a Java/Maven project, this typically means scanning the packaged JAR/WAR (or the `target/` directory) rather than just the source code, to ensure all library references are included. The IQ CLI can accept either a directory (e.g. a project workspace or target folder) or a single archive (e.g. a JAR, WAR, ZIP) as the _scan target_. It will automatically detect package manifests and component files (for example, `pom.xml`, `package.json`/`yarn.lock`, etc.) within that target to gather component data for evaluation.

**Performing the Scan:** In the CI workflow, add a step to execute the Sonatype IQ scan after the build/test stages. If using the CLI directly, the syntax is:

```bash
java -jar nexus-iq-cli.jar \
  -s http://your-iq-server:8070 \
  -a "${SONATYPE_USERNAME}:${SONATYPE_PASSWORD}" \
  -i YourAppID \
  -t build \
  ./target
```

In this example, `-s` specifies the IQ Server URL, `-a` provides the auth (user token or user:pass), `-i` sets the Application Public ID, `-t build` chooses the stage (defaults to “build” if not given), and `./target` is the path to scan. The CLI will package up relevant data (coordinates of dependencies, etc.) and send it to the Nexus IQ Server for policy evaluation. The IQ Server compares the components against your organization’s policies (security vulnerabilities, license checks, etc.) and then returns a result (pass, or policy violations with details). By default, the CLI exits with a non-zero status if any policy _failure_ is found (e.g. a security issue that violates a “critical” policy that is configured to fail the build), so your GitHub Action can detect this and mark the build failed.

**Stages and Application Context:** Ensure you use the correct **Application ID** (as configured in IQ Server) and an appropriate **stage** for the scan. Common stages are “Build”, “Develop”, “Stage Release”, “Release” – these correspond to different policy thresholds. Most CI integrations run at the “Build” stage by default. The Application Public ID ties the scan to a particular project profile in IQ Server (so the results are viewable in the IQ Server UI under that application). If the application doesn’t exist yet in IQ Server, you can enable **Automatic Application Creation** so that the first scan will create it on the fly (you may need to specify an organization ID for placement, or have a default org).

Once the CLI completes the scan, it will provide a link to the IQ Server report and a summary of policy actions. For example, the CLI output (or result file) includes fields like a `reportHtmlUrl` for the detailed report on the IQ Server, a `policyAction` (e.g. none, warn, or fail), and counts of violations. At this point, the data is in Sonatype’s hands for you to review or to propagate into GitHub as needed.

## 5. Networking and Connectivity

Integrating these tools in a self-hosted runner requires proper network configuration:

- **IQ Server Access:** The runner must be able to reach the Sonatype IQ Server’s endpoint. By default, IQ Server listens on port **8070/TCP** for HTTP (or whatever port is configured for IQ’s base URL). If your IQ Server is on-premises, ensure that the runner’s network can resolve the host and connect on the required port (e.g. open firewall from runner to IQ Server). For SSL setups, IQ Server might be fronted by a reverse proxy on 443 – adjust accordingly. The IQ Server’s base URL (including port) should be used in the CLI configuration (e.g. `http://iq-server.company:8070` or `https://iq.company.com`).
    
- **Allow-Lists and Firewalls:** If the runner is in a restricted network or the IQ Server is hosted externally (e.g. Sonatype Nexus Lifecycle in SaaS form or in another network segment), update your allow-lists. The runner’s IP/network should be permitted to send requests to the IQ Server API. Conversely, if the IQ Server calls back or webhooks to other systems, configure those as needed (though for basic scans, the runner initiates the connection).
    
- **Proxy Configuration:** In corporate environments where outbound traffic must go through a proxy, you may need to configure the IQ CLI to use it. The Sonatype GitHub Action and CLI support proxy settings. For instance, the GitHub Action takes optional inputs like `proxy` (host:port) and `proxyUser` (credentials). With the raw CLI, you can set environment variables (`HTTP_PROXY`, `HTTPS_PROXY`) or use JVM args if needed. Ensure the proxy allows traffic to the IQ Server. (If the IQ Server is inside the firewall with the runner, a proxy might not be needed for that, but possibly for reaching Sonatype data services.)
    
- **Sonatype Data Services:** The IQ Server itself (not the runner) needs outbound internet access on HTTPS (443) to retrieve vulnerability data from Sonatype’s data services (at **clm.sonatype.com**). This is typically handled by your Ops team when installing IQ Server, but be aware that if IQ Server cannot update its vulnerability database, scans might be slower or data might be stale. If your IQ server is offline, Sonatype can provide offline data packs.
    
- **Self-Hosted Runner Specs:** Ensure the runner machine has sufficient resources and any necessary tools. The Sonatype CLI for Java requires a JVM available (if you’re not using the Docker image or the action’s bundled JRE). Also, if using Docker-based GitHub Actions on the runner, the runner needs permission to run Docker containers. Network DNS should resolve your internal services (IQ server, Vault, etc.).
    

In summary, open **port 8070** (or your configured IQ port) from the runner to IQ Server, configure proxies if needed, and verify no corporate firewall rules are blocking the communication. This will allow the CLI on the runner to upload scan data and retrieve results from the Sonatype server.

## 6. Example GitHub Actions Workflow and CLI Usage

Below is a **minimal GitHub Actions workflow** example that runs a Nexus Lifecycle scan in a self-hosted runner job. This assumes a Java project using Maven for illustration, but the pattern is similar for other languages:

```yaml
name: Nexus Lifecycle Policy Scan
on: push

jobs:
  build-and-scan:
    runs-on: self-hosted  # using a self-hosted runner
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Set up JDK
        uses: actions/setup-java@v3
        with:
          distribution: 'Temurin'
          java-version: '17'

      - name: Build with Maven
        run: mvn -B package

      - name: Sonatype Lifecycle Policy Evaluation
        uses: sonatype/actions/evaluate@v1
        with:
          iq-server-url: ${{ secrets.SONATYPE_LIFECYCLE_URL }}
          username: ${{ secrets.SONATYPE_LIFECYCLE_USERNAME }}
          password: ${{ secrets.SONATYPE_LIFECYCLE_PASSWORD }}
          application-id: ${{ github.repository }}   # e.g. use repo name as app ID
          stage: Build
          scan-targets: "target/"  # scan the build output directory
          upload-sarif-file: true  # (if you want results in GitHub security tab)
```

This workflow performs a checkout, sets up Java (for the build and CLI runtime), builds the project, then invokes the **Sonatype evaluate action**. The `evaluate@v1` action wraps the steps of downloading the Sonatype CLI, running it with the provided parameters, and (optionally) uploading a SARIF results file for GitHub code scanning. We pass in our secrets for the server URL and credentials, the application ID, and specify the stage and scan target. In this example, we scan the `target/` directory which contains the packaged artifact and dependency jars from the Maven build. The `upload-sarif-file: true` flag instructs the action to generate a SARIF report and integrate with GitHub Advanced Security (so that any policy violations show up as code scanning alerts). If you only want the evaluation and not GitHub’s code scanning, you can omit that parameter.

After this step, the action outputs some data (like `scan-id` and `report-url`). You could add a step to log or use these outputs, for example:

```yaml
      - name: Output Scan Result Info
        run: echo "Scan ID: ${{ steps['Sonatype Lifecycle Policy Evaluation'].outputs.scan-id }} - Report: ${{ steps['Sonatype Lifecycle Policy Evaluation'].outputs.report-url }}"
```

The job will **fail automatically** if a policy violation is serious enough to trigger a failure action in IQ Server (the CLI exits with a non-zero status for policy failures). Less serious violations may allow the job to succeed but still report issues (in the Security tab or via the report URL). You can adjust policy actions in IQ Server (e.g. warn vs fail) to control this behavior.

**Equivalent CLI Command:** The above action ultimately runs a CLI command akin to the earlier example. If you wanted to run it manually (for debugging or in a custom script step), it would look like:

```bash
java -jar path/to/nexus-iq-cli.jar \
  -s "$SONATYPE_LIFECYCLE_URL" \
  -a "$SONATYPE_LIFECYCLE_USERNAME:$SONATYPE_LIFECYCLE_PASSWORD" \
  -i "YourApplicationID" \
  -t build \
  target/
```

This is essentially the same as what the GitHub Action does under the hood. (If you have the CLI jar pre-downloaded or cached on your runner, you could run it directly. In most cases, though, using the official Action is simpler as it handles downloading the correct CLI version and formatting the SARIF.)

## 7. Output Formats and Result Consumption

A Nexus Lifecycle evaluation produces several **output formats** that you can leverage:

- **Sonatype IQ Server Report (HTML/PDF):** Every scan is recorded in the IQ Server. The CLI output provides a URL to the detailed HTML report on the IQ Server (`reportHtmlUrl`) and even a direct link to a PDF export (`reportPdfUrl`). Team members can log into the IQ Server web interface to see a dashboard of applications, security and license violations, trends over time, and drill down into specific components. This is useful as an internal dashboard (no extra work needed – it’s built into Nexus Lifecycle). For an **external company tool**, you could use IQ Server’s REST APIs to pull violation data or subscribe to IQ webhooks for policy events, then aggregate those into your own system if needed.
    
- **JSON Policy Evaluation Result:** The CLI can produce a structured JSON output of the scan results. By using the CLI’s `--result-file` option (or the `result-file` parameter in the GitHub Action), you can save the full evaluation results as a JSON file. This JSON includes the application ID, scan ID, a summary of counts (e.g. number of components with vulnerabilities of various severities), and a list of policy violation details. For example, it will list each component that violated a policy and why. This JSON file can be archived as a build artifact or parsed by scripts for custom notifications. In the GitHub Action, setting `result-file: someName.json` will attach that JSON to the workflow run artifacts. You could then have a subsequent job consume it (e.g., send it to a company’s dashboard API or generate metrics).
    
- **SARIF (Security Alerts):** SARIF is the format used by GitHub Advanced Security to display code scanning alerts natively. Sonatype’s integration can emit SARIF so that vulnerabilities appear under **GitHub Checks/Security tab**. By enabling the `upload-sarif-file` option (as shown above), the action will generate a SARIF file (essentially converting the policy violations into “alerts” that GitHub can show). The SARIF is either automatically uploaded to GitHub (if using the Sonatype action’s integration) or can be uploaded via the `actions/upload-sarif` if doing it manually. The SARIF file typically contains each policy violation as a “rule” with instances, so developers can see descriptions and remediation guidance directly in GitHub. This method is great for surfacing issues without leaving GitHub, but note that it requires the Advanced Security feature on your plan.
    
- **SBOM (CycloneDX):** Sonatype IQ can generate a Software Bill of Materials for the scanned application. Using the **Fetch SBOM Action** or the IQ Server API, you can retrieve a CycloneDX SBOM (an XML or JSON listing of all components) for compliance or inventory purposes. The Sonatype GitHub Action set includes a `fetch-sbom@v1` action that, given a `scan-id` from a prior evaluation, will pull the SBOM file. This SBOM can be archived or fed into other tools (e.g., an internal vulnerability dashboard or asset management system). SBOMs are often used for governance and can be imported into other security tools if needed.
    
- **Logs and Console Output:** Don’t overlook the raw console output of the CLI run (viewable in the GitHub Actions logs). It provides a high-level summary of the scan (e.g., “X critical, Y severe, Z moderate policy violations found”) which can be captured as a check run output or used to fail the build. However, for any automated routing of results, it’s better to use the structured outputs above.
    

**Consuming Results in GitHub Checks:** If a policy fails the build, GitHub will mark the workflow as failed, which already surfaces an indication in the pull request or commit status (a “failed check” with the name of your workflow). For more nuanced reporting, the SARIF integration is ideal, as it creates code scanning alerts. Each alert includes details and links back to Sonatype data. Additionally, you can configure the Sonatype IQ Server to comment on pull requests or send notifications, but those are more relevant to PR integrations outside of Actions scope.

**Routing to External Dashboards:** Many companies aggregate scan results into central dashboards. To do this with Sonatype data, you have a few options:

- Use the JSON results: After each scan, push the JSON (or a processed summary) to your dashboard’s API.
    
- Use Sonatype’s IQ Server APIs: IQ Server has endpoints (v2 REST APIs) to fetch reports, list policy violations, etc., by application or scan ID. For example, given the `scanId` output, you could call IQ Server’s report API to get detailed results and then transform that for your system.
    
- Use Webhooks: IQ Server can send a webhook on policy evaluation events (success/fail) which includes the application and a report link. Your external system could listen for these and then pull the data.
    
- Or simply rely on the IQ Server UI as the dashboard – it provides a comprehensive view of risk across all applications.
    

Choose the format that best fits your workflow: **SARIF for GitHub UI**, **JSON/XML for machine processing**, and the **IQ Server’s native reports for interactive analysis**.

## 8. Scan Duration and Performance Optimization

For a codebase of around 5,000 lines (which typically implies a modest number of dependencies), **expected scan duration** is on the order of seconds to a couple of minutes at most. The Nexus IQ policy evaluation is designed to be fast and to fit into CI pipelines. In practice, scanning a small-to-medium application often completes in well under a minute once dependencies are resolved, because the work primarily involves identifying components and looking them up against Sonatype’s data (which IQ Server caches). If the IQ Server has seen the components before (common libraries, etc.), it likely has the data cached, making subsequent scans faster. The first scan of a new component may take a bit longer as IQ might fetch data from Sonatype’s services, but this is usually still relatively quick.

Several **tunable parameters and best practices** can help optimize scan performance:

- **Scan the Right Artefacts:** Feed the IQ CLI a focused target. Scanning the final artifact or build output (as recommended) limits the analysis to relevant files, avoiding redundant scanning of source files or unused modules. For example, scanning `target/myapp.jar` is faster and more accurate than scanning the entire repository, which might include source, docs, and other files that don’t affect the component analysis.
    
- **Exclude Unneeded Files:** If your workspace contains large directories that don’t need scanning (node_modules, test data, etc.), exclude them. The Sonatype action/CLI supports exclusion patterns (`module-exclude`) to ignore certain paths or files. This can reduce scan I/O overhead.
    
- **Reachability Analysis:** Sonatype offers an optional **Reachability Analysis** for Java apps, which examines your compiled code to determine if vulnerable methods are actually called. While valuable for prioritization, this deep analysis adds some overhead (it requires scanning all classes in the target for usage of vulnerable code). It’s off by default; only enable it (`-Dsonatype.scan.reachability=true` or similar CLI param) if you need that insight, and be aware it may lengthen the scan, especially for larger codebases. For a 5k LOC Java app, the impact is small, but for bigger projects, turning this on can increase scan time.
    
- **Resources for IQ Server:** Ensure the IQ Server has adequate CPU and memory allocated. The performance of the evaluation largely depends on the server’s ability to process component data. For most small scans this isn’t an issue, but concurrent large scans could tax the server. Monitoring the IQ Server’s health (CPU, heap usage) is recommended if you plan to scale up usage. Sonatype’s guidance for large-scale use includes using a robust database and possibly High Availability, but for a single 5k LOC app, a standard setup is fine.
    
- **Parallelism:** If your pipeline scans multiple projects, consider running scans in parallel if the IQ Server and network can handle it. IQ Server can queue and handle multiple evaluations, but too many at once might slow each down. Stagger or parallelize based on your performance observations.
    
- **CI Pipeline Optimizations:** You can cache the Sonatype CLI tool on the runner to avoid re-downloading it each run (though it’s not very large, on the order of tens of MB). If using the Docker container for the CLI, ensure the image is pre-pulled or cached on the runner to save time.
    
- **Network Latency:** Because the CLI sends data to the server, network latency can affect total time. Self-hosted runners on the same network as the IQ Server will have minimal latency. If there’s significant distance, consider locating runners closer to the IQ Server or using an on-prem server if internet latency was an issue (mostly relevant if using Sonatype’s cloud service).
    

In summary, a ~5000 LOC Java application scan should complete in a matter of **tens of seconds up to a minute or two** under normal conditions. By scanning the built artifact and using cached data, the impact on your build should be minimal. Tune the scope of scanning to avoid unnecessary work (focus on dependencies, not source), and only enable extra analysis if needed. With a properly configured environment, Nexus Lifecycle integrations provide quick feedback without significantly slowing down your CI/CD pipeline.

**Footnotes:**

1. Sonatype, _“Sonatype GitHub Actions – Overview and Code Scanning Integration”_
    
2. Sonatype Documentation, _“Sonatype IQ CLI – Usage and Authentication”_
    
3. Sonatype Documentation, _“Java Application Analysis – Scanning Build Artifacts”_
    
4. Sonatype, _GitHub Action Readme (Nexus IQ for GitHub Actions)_ – Example usage and parameters
    
5. Sonatype Help, _“User Tokens”_ – Recommended for CI authentication
    
6. GitHub Docs, _“Using secrets in GitHub Actions”_ – Secure storage of CI secrets
    
7. HashiCorp, _“Vault Action for GitHub”_ – Retrieving secrets from Vault in workflows
    
8. Sonatype Help, _“Integrations Capability Matrix”_ – Licensing requirement for Lifecycle integrations
    
9. Sonatype Blog, _“Secure your supply chain with Sonatype + GitHub”_ – Advanced Security and code scanning integration
    
10. Sonatype Help, _“IQ Server System Requirements”_ – Network ports (8070) and outbound requirements
    
11. Sonatype Help, _“Sonatype Lifecycle GitHub Action Parameters”_ – Proxy settings and scan outputs
    
12. Sonatype Help, _“Example Scan Result File”_ – JSON output structure of policy evaluation
    
13. Sonatype Help, _“Sonatype GitHub Actions – SARIF integration”_
    
14. Sonatype Help, _“Reachability Analysis (Java)”_ – Impact on scan (optional deep analysis)
    
15. Sonatype Best Practices, _“General Lifecycle Best Practices (CI/CD Integration)”_



## 9. Potential Blockers

1. **Licensing and Account Issues**
    
    - Verify if current Sonatype Nexus Lifecycle license supports automated CI scans.
        
    - Check license limits on the number of applications or developers allowed.
        
    - Confirm if GitHub Advanced Security is available for SARIF integration.
        
2. **Network and Connectivity**
    
    - Ensure the self-hosted runner has direct network access to IQ Server (default port 8070 or custom SSL port).
        
    - Validate DNS resolution and firewall rules permitting runner-to-server communication.
        
    - Address possible proxy requirements for runner-to-server and IQ Server-to-Sonatype data services connections.
        
3. **Authentication Management**
    
    - Confirm permissions of Sonatype CI service account (minimum privileges required).
        
    - Implement and test secure retrieval of credentials from GitHub Secrets or HashiCorp Vault.
        
4. **Scan Duration and Performance**
    
    - Initial scans of new projects/components might have higher latency due to data retrieval.
        
    - Consider potential scan time increases if optional features like Reachability Analysis are enabled.
        
    - Ensure adequate CPU and memory resources are provisioned for IQ Server and runner.
        
5. **Artifact Preparation for Scanning**
    
    - Clearly define the artifacts or directories to scan to avoid unnecessary processing overhead.
        
    - Verify that built artifacts contain all resolved dependencies for accurate scans.
        
6. **False Positives and Noise**
    
    - Potential for false-positive policy violations; plan for triaging results and tuning policies.
        
    - Identify and document strategies for managing noise from transitive dependencies.
        
7. **Runner Environment and Tool Dependencies**
    
    - Confirm self-hosted runner has necessary build tools (e.g., Maven, JDK, Docker if applicable).
        
    - Pre-cache Sonatype CLI or Docker images to minimize download overhead.
        
## 10. Open Questions to Resolve

1. **Licensing Clarifications**
    
    - Does the current Nexus Lifecycle license permit unlimited CI scans?
        
    - Is GitHub Advanced Security enabled and licensed for SARIF integration?
        
2. **Credential Management**
    
    - Which credential management solution (GitHub Secrets vs. Vault) aligns better with security requirements?
        
    - If Vault is used, is network connectivity and authentication to Vault reliably configured on the runner?
        
3. **Policy Configuration**
    
    - Which Nexus Lifecycle policy thresholds and stages (Build, Develop, Stage, Release) are most appropriate for initial CI scans?
        
    - Should Automatic Application Creation be enabled or will applications be manually pre-created?
        
4. **Artifact Scanning Approach**
    
    - What exact build output directories or files should the scanner target?
        
    - Will Reachability Analysis (for Java projects) be enabled from the outset?
        
5. **Performance and Scaling**
    
    - Do existing hardware resources meet the IQ Server and runner requirements for optimal scan durations?
        
    - What monitoring will be implemented to detect and respond to performance issues?
        
6. **Result Consumption and Reporting**
    
    - Will scan results be integrated directly into GitHub via SARIF, or pushed to a separate external dashboard?
        
    - Which teams will have responsibility for reviewing and managing policy violations reported?
        
7. **Proxy and Networking Specifics**
    
    - Are proxy settings required in the CLI and GitHub Action, and have these been properly tested?
        
    - Are there firewall adjustments required specifically for Sonatype data service updates from the IQ server?
        
8. **False Positives and Policy Maintenance**
    
    - What processes will be established to regularly review and adjust policies to reduce false positives?
        
    - Who will own policy maintenance, exception handling, and remediation tracking?

## References
1. [Sonatype GitHub Actions – Overview and Code Scanning Integration](https://help.sonatype.com/en/sonatype-github-actions.html) 
2. [Sonatype IQ CLI – Usage and Authentication](https://help.sonatype.com/en/sonatype-iq-cli.html)   
3. [Java Application Analysis – Scanning Build Artifacts](https://help.sonatype.com/en/java-application-analysis.html) 
4. [Nexus IQ for GitHub Actions – Example usage and parameters (README)](https://github.com/sonatype-nexus-community/iq-github-action/blob/main/README.md) 
5. [User Tokens – Recommended for CI authentication](https://help.sonatype.com/en/user-tokens.html) 
6. [Using secrets in GitHub Actions – Secure storage of CI secrets](https://docs.github.com/actions/security-guides/using-secrets-in-github-actions) 
7. [Vault Action for GitHub – Retrieving secrets from Vault in workflows](https://github.com/hashicorp/vault-action) 
8. [Integrations Capability Matrix – Licensing requirement for Lifecycle integrations](https://help.sonatype.com/en/integrations-compatibility.html) 
9. [Secure your software supply chain with Sonatype + GitHub](https://www.sonatype.com/blog/secure-your-software-supply-chain-with-the-sonatype-and-github-integration) 
10. [IQ Server System Requirements – Network ports (8070) and outbound requirements](https://help.sonatype.com/en/download-and-compatibility.html)
11. [Sonatype Lifecycle GitHub Action Parameters – Proxy settings and scan outputs](https://github.com/sonatype/actions/blob/main/run-iq-cli/README.md) 
12. [Example Scan Result File – JSON output structure](https://books.sonatype.com/sonatype-clm-book/1.26/html/book/evaluating-an-application-cli.html) 
13. [Sonatype GitHub Actions – SARIF integration](https://github.com/sonatype/actions/blob/main/evaluate/README.md) 
14. [Reachability Analysis (Java) – Impact on scan](https://help.sonatype.com/en/software-bill-of-materials-sbom.html)
15. [General Lifecycle Best Practices (CI/CD Integration)](https://help.sonatype.com/en/ci-and-cli-integrations.html) 
