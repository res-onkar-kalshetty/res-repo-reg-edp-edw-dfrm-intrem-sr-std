/**
 * Generates a BigQuery-safe SELECT clause string for anonymization views.
 * The returned SQL can be embedded safely inside an EXECUTE IMMEDIATE block.
 *
 * @param {object} options
 * @param {string} options.report_type - Standard report type filter.
 * @param {string} options.solution - Solution filter (e.g., 'MSP').
 * @param {string} options.metadata_table - Fully-qualified metadata table name.
 * @returns {string} SQL snippet to fetch anonymized SELECT clause.
 */
function get_anonymized_select_clause({
    report_type,
    solution,
    metadata_table
}) {
    // This SQL builds the anonymized SELECT clause dynamically and safely.
    // It will return a single STRING column containing comma-separated column expressions.
    return `
  (
    SELECT
      STRING_AGG(
        CASE
          WHEN anmyz_flag = 1 THEN
            CASE
              WHEN stdz_field_type = 'DATE'     THEN 'CAST("2020-01-01" AS DATE)'
              WHEN stdz_field_type = 'DATETIME' THEN 'CAST("2020-01-01 00:00:00" AS TIMESTAMP)'
              WHEN stdz_field_type = 'FLOAT64'  THEN 'CAST(1.0 AS FLOAT64)'
              WHEN stdz_field_type = 'INT64'    THEN 'CAST(1 AS INT64)'
              WHEN stdz_field_type = 'NUMERIC'  THEN 'CAST(1 AS NUMERIC)'
              ELSE CONCAT('TO_HEX(SHA256(CAST(\`', stdz_field_name, '\` AS STRING)))')
            END
          ELSE CONCAT('\`', stdz_field_name, '\`')
        END
        || ' AS \`' || stdz_field_name || '\`',
        ', ' ORDER BY stdz_field_name
      )
    FROM
      ${metadata_table}
    WHERE
      entity_type = '${report_type}'
      AND solution = '${solution}'
      AND active = 1
  )
  `;
}

module.exports = {
    get_anonymized_select_clause
};
