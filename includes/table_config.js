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

// function getTableNames(ctx) {
//     // Reference to dataset and metadata table
//     const datasetId = dataform.projectConfig.vars.dataset_id;
//     const metadataTable = `\`${datasetId}.table_a\``;

//     // Query to get mapping of standard_report_type → table_id
//     const rows = ctx
//         .runQuery(
//             `SELECT standard_report_type, table_id 
//        FROM ${metadataTable}
//        WHERE dataset_id = '${datasetId}'`
//         )
//         .rows;

//     // Build a lookup map from query result
//     const tableMap = {};
//     for (const row of rows) {
//         tableMap[row.standard_report_type] = row.table_id;
//     }

//     // Build defaults object dynamically
//     const defaults = {
//         candidate: dataform.projectConfig.vars.ph_candidate ||
//             tableMap["candidate"],
//         requisition_template: dataform.projectConfig.vars.ph_requisition_template ||
//             tableMap["requisition_template"],
//         requisition: dataform.projectConfig.vars.ph_requisition ||
//             tableMap["requisition"],
//         assignment: dataform.projectConfig.vars.ph_assignment ||
//             tableMap["assignment"],
//         assignment_v0: dataform.projectConfig.vars.ph_assignment_v0 ||
//             tableMap["assignment_v0"],
//         requisition_distribution: dataform.projectConfig.vars.ph_requisition_distribution ||
//             tableMap["requisition_distribution"],
//         assignment_rates: dataform.projectConfig.vars.ph_assignment_rates ||
//             tableMap["assignment_rates"],
//         assignment_rates_v0: dataform.projectConfig.vars.ph_assignment_rates_v0 ||
//             tableMap["assignment_rates_v0"],
//         worker: dataform.projectConfig.vars.ph_worker ||
//             tableMap["worker"],
//         spend: dataform.projectConfig.vars.ph_spend ||
//             tableMap["spend"],
//         supplier: dataform.projectConfig.vars.ph_supplier ||
//             tableMap["supplier"],
//     };

//     return {
//         defaults
//     };
// }

// function getCompleteTableConfig(ctx) {
//     const baseConfig = getTableNames(ctx);
//     return {
//         baseTables: baseConfig
//     };
// }

// module.exports = {
//     getCompleteTableConfig
// };


// const lookupQuery = `
//   SELECT rep_type, table_id FROM \`your_project.your_dataset.table_x\`
// `;

// const tableMappings = dataform.query(lookupQuery).then(result => {
//   const mappings = {};
//   result.forEach(row => {
//     mappings[row.rep_type] = row.table_id;
//   });
//   return mappings;
// });

// module.exports = { tableMappings };


