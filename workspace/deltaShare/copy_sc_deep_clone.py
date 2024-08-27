# Databricks notebook source
# DBTITLE 1,Fetch the source and target catalog names as parameters.
# Retrieve the catalog values entered as parameters.
source_catalog = dbutils.widgets.get("source_catalog")
target_catalog = dbutils.widgets.get("target_catalog")

# COMMAND ----------

# DBTITLE 1,Functions used to fetch the in-scope schemas and tables.
def get_schemas_from_catalog(catalog_source):
    try: 
        df_schemas = spark.sql(f'SHOW SCHEMAS IN {catalog_source}')
        lst_schemas = [s[0] for s in df_schemas.select('databaseName').collect()]
    except:
        print(f'Catalog {catalog_source} does not exist.')
        lst_schemas = []
    print(f'\nList of all the existing schemas in the catalog {catalog_source}\n',lst_schemas)
    return lst_schemas

def create_schema(catalog_source, catalog_target, schema_name):
    df_schemas = spark.sql(f'SHOW SCHEMAS IN {catalog_source}')
    lst_schemas = [t[0] for t in df_schemas.select('databaseName').collect() if t[0] == schema_name]
    if len(lst_schemas)>0:
        print(f'Creating schema {schema_name} on catalog {catalog_target}')
        spark.sql(f'CREATE SCHEMA IF NOT EXISTS {catalog_target}.{schema_name}')
    else:
        print(f'Schema {schema_name} does not exist in {catalog_source}.')

def get_tables_from_schema(catalog_source, schema_name):
    try: 
        df_tables = spark.sql(f'SHOW TABLES IN {catalog_source}.{schema_name}')
        lst_tables = [t[0] for t in df_tables.select('tableName').collect()]
    except:
        print(f'Schema {schema_name} does not exist in {catalog_source}.')
        lst_tables = []
    print(f'List of all the existing tables in the schema {schema_name}\n',lst_tables)
    return lst_tables


# COMMAND ----------

# DBTITLE 1,Copy the data from shared catalog to target catalog.
# Copy Full Catalog
for schema_name in get_schemas_from_catalog(source_catalog):
    create_schema(source_catalog, target_catalog, schema_name)
    for table_name in get_tables_from_schema(source_catalog, schema_name):
        if(schema_name != 'information_schema'):
            print(f'Cloning of table {source_catalog}.{schema_name}.{table_name} in-progress...')
            spark.sql(f'CREATE OR REPLACE TABLE {target_catalog}.{schema_name}.{table_name} CLONE {source_catalog}.{schema_name}.{table_name}')
            print('Cloning operation done')
