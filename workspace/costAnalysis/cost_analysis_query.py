# Databricks notebook source
 %sql # type: ignore
 SELECT workspace_id, u.sku_name, billing_origin_product, round(sum(usage_quantity), 2) as usage_quantity, u.usage_unit, round(sum(usage_quantity*price), 2) as usage_cost, currency_code, round(price, 2) as cost_per_dbu, # type: ignore
 currency_code from `system`.billing.usage u LEFT JOIN (select price_start_time, sku_name, currency_code, price from (select price_start_time, sku_name, currency_code, pricing.default as price, RANK() OVER (PARTITION BY sku_name ORDER BY price_start_time DESC) AS rank # type: ignore
 from `system`.billing.list_prices) where rank = 1) p on u.sku_name = p.sku_name WHERE usage_start_time > date_sub(CAST(current_timestamp() as DATE), 7) # type: ignore
 and usage_end_time < current_timestamp() and workspace_id in () GROUP BY u.sku_name, billing_origin_product, u.usage_unit, workspace_id, currency_code, price # type: ignore
 ORDER BY usage_cost desc # type: ignore