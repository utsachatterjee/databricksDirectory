output "repo"{
    value = tomap({ for k, s in databricks_repo.db_repo : k => s.id })
}