# res-repo-dataform-cd-template
Template repo for dataform cd pipelines

Configure the deploy.sh as per the use-case to create, update and manage release configs and workflows.

When a Cloud Build Trigger is being configured, make sure the variables \_ENV\_, _DFORM_LOCATION and _DFORM_NAME are provided as environment variables.

Configure the branch rules for the base repo as present in the [Risesmart Linkup Dataform repo](https://github.com/randstadrisesmart/res-repo-risesmart-linkup-dform/settings/rules)