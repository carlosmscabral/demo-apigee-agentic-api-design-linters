# Agentic API Design & Governance Demo

This project demonstrates how to refactor a legacy "Human-Centric" API into an "Agent-Ready" Cognitive Interface, and how to enforce these patterns using **Spectral** and **Google Cloud Build**.

## 📂 Project Structure

- **`human-centric/`**: Contains the legacy OpenAPI spec (The "Before").
- **`agentic/`**: Contains the refactored, agent-optimized OpenAPI spec (The "After").
- **`linters/`**: Contains the `agentic.yaml` Spectral ruleset that enforces agentic design patterns.
- **`cloudbuild.yaml`**: The CI/CD pipeline that lints, registers, and deploys the API.
- **`Article.md`**: A guide on the philosophy behind Agentic API Design.

## 🚀 Getting Started

### Prerequisites

1.  **Google Cloud Project** with:
    - Apigee X or Hybrid enabled.
    - API Hub enabled.
    - Cloud Build enabled.
2.  **`gcloud` CLI** installed and authenticated.
3.  **Permissions**: Ensure your Cloud Build Service Account has:
    - `Apigee API Admin`
    - `API Hub Admin` (or equivalent permissions to create APIs/Versions/Specs)

### Configuration

1.  Copy the environment template:
    ```bash
    cp .env.local .env
    ```
2.  Edit `.env` and fill in your details:
    ```bash
    PROJECT_ID=your-gcp-project-id
    APIGEE_ORG=your-apigee-org
    APIGEE_ENV=your-apigee-env
    API_HUB_REGION=us-central1
    ```

## 🛠️ Running the Pipeline

We use **Google Cloud Build** to automate the governance and deployment loop.

### Scenario 1: The "Happy Path" (Agentic Spec)

This scenario deploys the refactored `agentic/openapi.yaml`. It should **PASS** the linter, register in API Hub, and deploy to Apigee.

**Command:**

```bash
./deploy.sh
```

**Expected Outcome:**
- ✅ **Step 1 (Lint)**: Passes.
- ✅ **Step 2 (Register)**: API "Agentic Order API" is created/updated in API Hub.
- ✅ **Step 3 (Deploy)**: Proxy "agentic-order-api" is deployed to Apigee.

---

### Scenario 2: The "Failure Path" (Legacy Spec)

To demonstrate the governance controls, let's try to deploy the legacy `human-centric/openapi.yaml`. This should **FAIL** the linter and stop the pipeline.

**Command:**

```bash
./deploy.sh legacy
```

**Expected Outcome:**
- ❌ **Step 1 (Lint)**: **FAILS**.
    - `agent-semantic-operation-id`: "post_orders" is not semantic.
    - `agent-description-richness`: Description is missing or too short.
    - `agent-strict-schema`: `additionalProperties: false` is missing.
- 🛑 **Pipeline Stops**: The build fails, preventing the "bad" API from being registered or deployed.

## 🧹 Cleanup

To undeploy the proxy and remove the API from API Hub, run:

```bash
./cleanup.sh
```

## 🔍 The "Agentic" Linter Rules

The `linters/agentic.yaml` file enforces 6 key rules for AI compatibility:

1.  **Semantic Naming**: OperationIDs must be action-oriented (e.g., `submitOrder` vs `post_orders`).
2.  **Description Economy**: Descriptions must be detailed enough to serve as System Prompts.
3.  **Few-Shot Prompting**: Examples are mandatory.
4.  **Strict Mode**: `additionalProperties: false` is required to prevent hallucinations.
5.  **Explicit Requirements**: No implicit logic; required fields must be listed.
6.  **Reflexion**: Error responses must include a `hint` field.
