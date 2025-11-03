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

function get_region() {
    const regionCode = get_region_code();
    let region = '';
    if (regionCode=="eu") {
        region= "_emea";
    } else if (regionCode=="us") {
        region = "";
    } else {
        region = "_apac";
    }
    return region
}

function get_env() {
    const project = `${dataform.projectConfig.defaultDatabase}`.toLowerCase();
    let env = '';
    if (project.includes("dev")) {
        env = "dev";
    } else if (project.includes("prd")) {
        env = "prd";
    } else {
        env = project.split("-")[3];
    }
    return env
}

function get_config_ds() {
    const region_code = get_region_code();
    const env = get_env();
    const config_ds_prefix = constants[`config_dataset_name`];
    let config_ds_name = "";
    if (env === "prd") {
        config_ds_name = config_ds_prefix + '_' + region_code;
    } else {
        config_ds_name = env + '_' + config_ds_prefix + '_' + region_code;
    }
    return config_ds_name
}

function get_config_table() {
    return constants['config_table_name']
}

function getSlvrTableName(dataset,table,entity_type,dataset_id) {
    const keyName = entity_type.replace('_src', '');
    const placeholderKey = `ph_${keyName}`;
    const placeholderValue = dataform.projectConfig.vars && dataform.projectConfig.vars[placeholderKey];
    if (placeholderValue && placeholderValue.trim() !== '') {
    return `"${placeholderValue}"`;
  } else {
    return `(
        select
        distinct table_id
        from ${dataset}.${table}
        where standard_report_type='${entity_type}' and dataset_id='${dataset_id}')`
  }
}
module.exports = {
    get_region_code,
    get_region,
    get_env,
    get_config_ds,
    get_config_table,
    getSlvrTableName
}
