
# Victorian Council Financial Performance Intelligence

### End-to-End Data Engineering, Financial Analytics & Executive Reporting

**Tech Stack:** Databricks | PySpark | SQL | Delta Lake | Dimensional Modelling | Databricks AI/BI Dashboards

## Project Overview

Developed an end-to-end financial intelligence and reporting solution to analyse financial performance across **79 Victorian local councils over five financial years (2020–21 to 2024–25)**.

The project combines publicly available local government financial and performance datasets, applies data quality checks, builds reporting-ready datasets and delivers interactive dashboards to support financial monitoring and council benchmarking.

The goal was to turn fragmented financial data into consistent, explainable insights that council managers and analysts can use to identify trends, compare performance and prioritise further investigation.

## 1. Business Problem

Victorian councils operate under different financial conditions, population pressures and service delivery requirements.

Analysing their performance across multiple years can be challenging because:

- Financial information is distributed across multiple datasets.
- Data structures and naming conventions can vary.
- Missing values and inconsistent council names affect reporting reliability.
- Comparing councils requires consistent KPI definitions.
- Manual reporting makes it difficult to identify emerging financial pressures.

**Business objective:** Develop a repeatable financial reporting pipeline that improves data consistency, supports benchmarking and highlights councils requiring closer financial review.

## 2. Project Objectives

- Integrate five years of Victorian council financial data.
- Clean, standardise and validate financial and population datasets.
- Build a Bronze, Silver and Gold data processing workflow.
- Develop reporting-ready dimensional models.
- Calculate financial KPIs using SQL.
- Analyse five-year trends and council performance.
- Develop an interactive executive dashboard.
- Document data quality rules and reporting assumptions.

## 3. Data Sources

The project uses publicly available Australian government datasets, including:

- Victorian local government financial data
- Council performance indicators
- Council classification and category data
- Australian Bureau of Statistics population data

**Analysis period:** 2020–21 to 2024–25

**Geographic coverage:** 79 Victorian local government areas

Source files, definitions and any applicable redistribution conditions should be checked against the original publishers.

## 4. Data Engineering Architecture

Implemented a layered data processing approach using Databricks and PySpark.

**Bronze Layer — Raw Data Ingestion**

- Ingested multi-year council datasets.
- Combined financial-year records.
- Preserved source data for traceability.
- Reviewed source schemas and column consistency.

**Silver Layer — Data Cleaning and Validation**

- Standardised council names and column formats.
- Reviewed missing and inconsistent values.
- Applied data type corrections.
- Integrated financial and population datasets.
- Performed reconciliation and data quality checks.

**Gold Layer — Reporting and Analytics**

- Prepared validated reporting datasets.
- Developed dimensional modelling logic.
- Created SQL-based financial KPI calculations.
- Produced council benchmarking and trend analysis datasets.
- Supported executive dashboard reporting.

### Pipeline Overview

Raw CSV / Excel Data → Bronze Ingestion → Silver Cleaning & Validation → Gold Reporting Tables → SQL Analysis → Databricks AI/BI Dashboard

## 5. SQL Analytics and Financial KPIs

Developed SQL analysis to examine council financial performance, including:

- Operating results and financial sustainability
- Liquidity and financial position
- Indebtedness and funding pressures
- Capital replacement and renewal indicators
- Five-year financial performance trends
- Council-level comparisons and benchmarking
- Financial review-priority screening

The analysis focuses on identifying patterns and areas for further investigation rather than assigning official financial risk ratings.

## 6. Executive Dashboard

Built a Databricks AI/BI dashboard to communicate financial performance to non-technical stakeholders.

### Dashboard Capabilities

- Executive KPI overview
- Council-level financial comparisons
- Five-year performance trends
- Financial review-priority indicators
- Council benchmarking
- Financial performance commentary

### Dashboard Preview

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/bf81ff71-c4b2-46a9-a114-0f961ffafe7f" />



Example Markdown after uploading a screenshot:

`![Executive Dashboard](dashboards/Executive_Overview.png)`

## 7. Key Analytical Findings

The project's financial screening identified:

- **9 councils** in a high analytical priority category.
- **13 councils** requiring financial review under the project's screening criteria.
- Additional councils identified for monitoring or further investigation.

The dashboard also provides trend and benchmarking analysis to support interpretation of these results.

**Important:** These categories are project-defined analytical flags, not official Victorian Government financial risk classifications. Screening results depend on the selected indicators, thresholds, data completeness and reporting assumptions.

## 8. Data Quality and Validation

Data reliability was a major focus of the project.

Validation activities included:

- Reviewing schema consistency across financial years.
- Checking missing values and data types.
- Standardising council identifiers and names.
- Reconciling integrated datasets.
- Validating reporting outputs against source data.
- Reviewing incomplete records before KPI interpretation.

These checks help ensure that dashboard outputs are traceable and suitable for analytical reporting.

## 9. Repository Structure

```text
victorian-council-financial-intelligence/
├── README.md
├── notebooks/
│   └── Databricks PySpark notebooks
├── SQL/
│   └── Financial analysis and modelling scripts
├── data/
│   └── Dataset information and samples
└── dashboards/
    └── Dashboard screenshots and supporting files
```

## 10. Technical Skills Demonstrated

| Area | Skills |
|---|---|
| Data Engineering | Databricks, PySpark, Delta Lake |
| Data Preparation | Data cleaning, transformation, integration |
| Data Quality | Validation, reconciliation, missing-value analysis |
| Data Modelling | Dimensional modelling, reporting tables |
| SQL Analytics | Aggregations, joins, financial KPI calculations |
| Business Intelligence | Databricks AI/BI Dashboards |
| Financial Analysis | Trend analysis, benchmarking, KPI reporting |
| Documentation | Reporting assumptions, data quality and methodology |

## 11. Business Value

This project demonstrates how a repeatable analytics workflow can support local government reporting by:

- Reducing reliance on manual data preparation.
- Improving consistency in financial KPI calculations.
- Making council performance easier to compare.
- Highlighting financial indicators that warrant further investigation.
- Presenting complex analytical results in an accessible executive dashboard.

These are demonstrated capabilities and potential benefits of the prototype, not measured operational improvements from a council deployment.



---

## Author

**Shivani Malik**

Master of Data Science — RMIT University

Graduate Data Analyst | Reporting Analyst

Interested in data analytics, business intelligence, utilities and local government reporting.

[GitHub Profile](https://github.com/Shivani-Malik-Data)

*Independent portfolio project using publicly available data. Not an official Victorian council or government reporting product.*
