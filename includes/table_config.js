function getTableNames(ctx) {
    const defaults = {
        candidate: dataform.projectConfig.vars.ph_candidate || "prs_candidate",
        requisition_template: dataform.projectConfig.vars.ph_requisition_template || "prs_requisition_template",
        requisition: dataform.projectConfig.vars.ph_requisition || "prs_requisition",
        assignment: dataform.projectConfig.vars.ph_assignment || "prs_assignment",
        assignment_v0: dataform.projectConfig.vars.ph_assignment_v0 || "prs_assignment_v0",
        requisition_distribution: dataform.projectConfig.vars.ph_requisition_distribution || "prs_requisition_distribution",
        assignment_rates: dataform.projectConfig.vars.ph_assignment_rates || "prs_assignment_rates",
        assignment_rates_v0: dataform.projectConfig.vars.ph_assignment_rates_v0 || "prs_assignment_rates_v0",
        worker: dataform.projectConfig.vars.ph_worker || "prs_worker",
        spend: dataform.projectConfig.vars.ph_spend || "prs_spend",
        supplier: dataform.projectConfig.vars.ph_supplier || "prs_supplier",
    };
    return {
        defaults
    };
}

function getCompleteTableConfig(ctx) {
    const baseConfig = getTableNames(ctx);
    return {
        baseTables: baseConfig,
    };
}
module.exports = {
    getCompleteTableConfig,
};
