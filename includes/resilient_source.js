/**
 * @fileoverview A generic helper to create a resilient data source in Dataform.
 * It generates a SQL query that, when executed, produces a `SELECT` clause string.
 * This clause includes all columns from a schema registry, substituting NULL for any
 * columns that are missing from the physical source table.
 */

/**
 * Generates a SQL query string that builds a resilient SELECT clause.
 *
 * @param {string} source_table_name - The name of the physical source table.
 * @param {string} source_dataset - The dataset of the physical source table.
 * @param {string} registry_table_fqn - The fully-qualified name of the schema registry table(external tale).
 * @param {string} gold_template_id - The ID of the gold model to filter the registry.
 * @param {string} entity_type - report type to filter the registry.
 * @param {string} source - source of the client
 * @returns {string} A SQL query that will return a single string: the resilient SELECT clause.
 */



function resilient_source(source_table_name, source_dataset, registry_dataset, entity_type, gold_template_id, source) {
    return `
    SELECT
        STRING_AGG(
          CASE 
            -- Column exists in physical Silver table: Select it normally
            WHEN T2.column_name IS NOT NULL 
              THEN 'T_SOURCE.' || T1.slvr_field_name || ' AS ' || T1.slvr_field_name
              
            -- Column does NOT exist yet (Scrum team hasn't added it): Inject NULL
            ELSE '/* INFO: Awaiting ' || T1.slvr_field_name || ' */ CAST(NULL AS ' || T1.data_type || ') AS ' || T1.slvr_field_name
          END
        )
    FROM ${registry_dataset}.ext_gold_schema_registry AS T1
    LEFT JOIN (
        SELECT column_name FROM ${source_dataset}.INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'v_' || ${source_table_name}
    ) AS T2 ON T1.slvr_field_name = T2.column_name
    WHERE T1.entity_type = '${entity_type}' 
      AND T1.gold_template_id = '${gold_template_id}'
      AND T1.source = '${source}'`;
}

module.exports = {
    resilient_source
};
