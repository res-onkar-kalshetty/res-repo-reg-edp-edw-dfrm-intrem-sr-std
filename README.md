# Gold Layer Module

This repository contains the Gold Layer of our data pipeline, which is responsible for producing both gold (final reporting) and anonymized (anmz) tables. The Gold Layer is executed after the Silver (slvr) layer and is orchestrated by Airflow as part of the ETL workflow.

## Overview

- **Purpose:**  
  The Gold Layer transforms and uses data from the Silver Layer, generating final reporting tables (`gold`) and their anonymized versions (`anmz`) for analytics, reporting for different solutions.

- **Execution Flow:**  
  Airflow triggers the process, passing parameters such as `dataset_id`, `client_code`, and `dataset_name` (legacy database name). The pipeline uses these parameters to dynamically generate and execute the required SQLX templates.

- **Tag-Based Processing:**  
  Templates are tagged by client or report type (e.g., `msp_bee_template_gold`). Tags allow selective execution of templates, and dependencies between templates ensure that related reports are processed together.

- **Custom Report/View Names:**  
  The system supports custom naming for reports and views, providing flexibility for client-specific requirements. These custom report names can be passed with dataform invocation arguments.

- **Failure Propagation:**  
  If a report fails, all dependent reports will also fail, ensuring data consistency and integrity.

- **Prerequisites:**  
  Ensure that the `slvr`, `gold`, and `anmz` datasets exist before running Dataform.


## Input Parameters

The Gold Layer is configured using parameters passed by Airflow or the orchestrator. These parameters control which data is processed and how the templates are rendered.

| Parameter         | Required | Description                                                                                  | Example                |
|-------------------|:--------:|----------------------------------------------------------------------------------------------|------------------------|
| `dataset_id`      | **Yes**  | Unique identifier for the dataset/client. Used to construct dataset and table names.          | `eu_nike`              |
| `client_code`     | **Yes**  | Short code for the client, used for tagging and template selection.                          | `nike`                 |
| `dataset_name`    | **Yes**  | Legacy or descriptive name for the dataset, used for compatibility or reporting.             | `db_gbl_nike`       |
| `env`             | No       | Execution environment. Determines dataset prefixes. Defaults to `dev`.                       | `prd`                  |
| `custom_reports`  | No       | Comma-separated list of custom report/view names to use.                                | `t_emea_bee_api_msp_assign_dy`|
| `tags`            | No       | Comma-separated list of tags to filter which templates are executed.                         | `msp_bee_template_gold`|
| `region`          | No       | Cloud region for resource resolution.                                                        | `us-central1`          |
| `additional_args` | No       | Any additional arguments for advanced configuration or future use.                            | `{"key":"value"}`      |

**How these parameters are used:**
- `dataset_id`, `client_code`, and `dataset_name` are used to dynamically resolve dataset/table names and select the correct templates.
- `env` determines whether the pipeline runs in development or production mode, affecting dataset prefixes (e.g., `dev_gold_` vs. `gold_`).
- `custom_reports` and `tags` allow fine-grained control over which reports/views are generated.
- `region` is used for region-specific resource resolution.
- `additional_args` can be used for future extensibility.


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

workflow_settings.yaml
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

## Best Practices

- Use tags to control which templates are executed for each client or report type.

## References

- [Dataform Documentation](https://docs.dataform.co/)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)

---

For questions or contributions, refer to [CODEOWNERS](.github/CODEOWNERS).
