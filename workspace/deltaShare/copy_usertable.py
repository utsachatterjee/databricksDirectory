# Databricks notebook source
# Retrieve the catalog values entered as parameters.
catalogs_list = {}
source_list = {}

# COMMAND ----------


for catalog,schema_list in source_list.items():
    target_catalog = catalogs_list[catalog]
    for schema,table_list in schema_list.items():
        try:
            spark.sql(f'CREATE SCHEMA IF NOT EXISTS `{target_catalog}`.{schema}')
            print(f'schema created {catalog}.{schema}')
            for table in table_list:
                print(f'table is reading {catalog}.{schema}.{table}')
                df = spark.read.format("delta").table(f'`{catalog}`.{schema}.{table}')
                df.write.mode("overwrite").format("delta").option("overwriteSchema", "true").saveAsTable(f'`{target_catalog}`.{schema}.{table}')
                print(f'table written {target_catalog}.{schema}.{table}')
        except Exception as e:
            print(e)

