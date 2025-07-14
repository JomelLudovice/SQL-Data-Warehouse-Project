/*
================================================================================
Quality Checks
================================================================================
Script Purpose: 
	This script performs various quality checks for data consistency, accuracy,
	and standardization across the 'silver' schema. It includes checks for:
		- Nulls or duplicates primary keys.
		- Unwanted spaces in string fields.
		- Data standardization and consitency.
		- Invalid date ranges and orders.
		- Data consistency between related fields.

Usage Notes:
	- Run these checks after data loading silver layer.
	- Investigate and resolve any discrepancies found during the checks.
================================================================================
*/
