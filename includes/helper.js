const constants = require('./constants');


function get_region_code() {
    const locationLower = `${dataform.projectConfig.defaultLocation}`.toLowerCase();
    let regionCode = '';
    if (locationLower.includes("europe")) {
        regionCode = "eu";
    } else if (locationLower.includes("us") || locationLower.includes("america")) {
        regionCode = "us";
    } else {
        regionCode = "apac";
    }
    return regionCode
}

function get_config_ds() {
    const region_code = get_region_code();
    const config_ds_prefix = constants[`config_dataset_name`]
    let config_ds_name = "";
    // dev_reg_edp_edw_schema_eu
    if ("${dataform.projectConfig.vars.env}" === "prd") {
        config_ds_name = config_ds_prefix + '_' + region_code;
    } else {
        config_ds_name = `${dataform.projectConfig.vars.env}` + '_' + config_ds_prefix + '_' + region_code;
    }
    return config_ds_name
}

function get_config_table() {
    return constants['config_table_name']
}

module.exports = {
    get_region_code,
    get_config_ds,
    get_config_table
}
