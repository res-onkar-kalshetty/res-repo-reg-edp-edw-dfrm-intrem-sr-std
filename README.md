# My Own Description

This repository contains the Gold Layer of our data pipeline, which is responsible for producing both gold (final reporting) and anonymized (anmz) tables. The Gold Layer is executed after the Silver (slvr) layer and is orchestrated by Airflow as part of the ETL workflow.

## Overview

- **Purpose:**  
  The Gold Layer transforms and aggregates data from the Silver Layer, generating final reporting tables (`gold`) and their anonymized versions (`anmz`) for analytics, reporting, and compliance.

- **Execution Flow:**  
  Airflow triggers the process, passing parameters such as `dataset_id`, `client_code`, and `dataset_name` (legacy database name). The pipeline uses these parameters to dynamically generate and execute the required SQLX templates.

- **Tag-Based Processing:**  
  Templates are tagged by client or report type (e.g., `msp_bee_template_gold`). Tags allow selective execution of templates, and dependencies between templates ensure that related reports are processed together.

- **Custom Report/View Names:**  
  The system supports custom naming for reports and views, providing flexibility for client-specific requirements.

- **Failure Propagation:**  
  If a report fails, all dependent reports will also fail, ensuring data consistency and integrity.

- **Prerequisites:**  
  Ensure that the `slvr`, `gold`, and `anmz` datasets exist before running Dataform.

## Repository Structure

```
includes/
  anonymization.js      # Generates anonymized SELECT clauses
  constants.js          # Dataset/table name constants
  helper.js             # Environment/config utility functions
  table_config.js       # Table and config resolution logic

definitions/
  msp_bee_templates/
  msp_ntv_templates/
  msp_sow_templates/
  msp_templates/
  msp_vn_templates/
  rpo_templates/
    anmz/               # Anonymized SQLX templates (For all templates)
    gold/               # Gold (raw) SQLX templates (For all templates)

deploy/
  deploy.sh             # Main deployment script
  validate_build.sh     # Pre-deployment validation

.github/
  CODEOWNERS
  workflows/
  pull_request_template.md
```

## Key Components

- **SQLX Templates:**  
  Located in `definitions/`, these templates dynamically generate tables and views based on configuration, environment, and tags.

- **Includes:**  
  JavaScript helper modules for anonymization, configuration, and environment detection, used within SQLX templates for dynamic logic.

- **Deployment Scripts:**  
  Scripts in `deploy/` automate Dataform release, workflow creation, and build validation.

- **GitHub Workflows:**  
  Repository governance and CI/CD automation, including PR templates and code ownership.

## Getting Started

1. **Set Environment Variables:**  
   Configure `_ENV_`, `_DFORM_LOCATION`, and `_DFORM_NAME` for Cloud Build triggers or your deployment environment.

2. **Deploy:**  
   - Run `deploy/deploy.sh` to automate release and workflow creation.
   - Use `deploy/validate_build.sh` to validate build and branch naming conventions.

3. **Manage Templates:**  
   Add or modify SQLX templates in `definitions/` to support new reports or clients.

4. **Extend Logic:**  
   Update or extend helper functions in `includes/` for custom anonymization or environment logic.

## Best Practices

- Use tags to control which templates are executed for each client or report type.
- Maintain clear dependencies between templates to ensure correct execution order.
- Regularly update helper scripts to accommodate new anonymization or configuration requirements.
- Use GitHub workflows and PR templates to enforce code quality and review standards.

## References

- [Dataform Documentation](https://docs.dataform.co/)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)

---

For questions or contributions, refer to [CODEOWNERS](.github/CODEOWNERS).