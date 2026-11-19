
SELECT
    Category,
    SubCategory,
    COUNT(*) AS Records,
    COUNT(DISTINCT Council) AS Councils,
    COUNT(DISTINCT FinancialYear) AS Years
FROM workspace.default.fact_financial
GROUP BY Category, SubCategory
ORDER BY Category, SubCategory;






SELECT
    Category,
    SubCategory,
    COUNT(*) AS Records,
    MIN(Value) AS MinimumValue,
    MAX(Value) AS MaximumValue,
    SUM(CASE WHEN Value < 0 THEN 1 ELSE 0 END) AS NegativeValues,
    SUM(CASE WHEN Value = 0 THEN 1 ELSE 0 END) AS ZeroValues
FROM workspace.default.fact_financial
WHERE Category IN ('Revenue', 'Expenses')
GROUP BY Category, SubCategory
ORDER BY Category, SubCategory;






SELECT
    Council,
    FinancialYear,
    ROUND(
        SUM(CASE WHEN Category = 'Revenue'
                 THEN Value ELSE 0 END), 2
    ) AS TotalRevenue,
    ROUND(
        SUM(CASE WHEN Category = 'Expenses'
                 THEN Value ELSE 0 END), 2
    ) AS TotalExpenses,
    ROUND(
        SUM(CASE WHEN Category = 'Revenue'
                 THEN Value
                 WHEN Category = 'Expenses'
                 THEN -Value
                 ELSE 0 END), 2
    ) AS PreliminaryOperatingResult
FROM workspace.default.fact_financial
WHERE Category IN ('Revenue', 'Expenses')
GROUP BY Council, FinancialYear
ORDER BY Council, FinancialYear;






SELECT
    Category,
    `SubCategory`,
    COUNT(*) AS Records,
    COUNT(DISTINCT Council) AS Councils,
    COUNT(DISTINCT FinancialYear) AS Years
FROM workspace.default.fact_financial
WHERE LOWER(Category) LIKE '%revenue%'
   OR LOWER(Category) LIKE '%expense%'
GROUP BY Category, `SubCategory`
ORDER BY Category, `SubCategory`;





WITH council_years AS (
    SELECT DISTINCT
        Council,
        FinancialYear
    FROM workspace.default.fact_population
),
contribution_types AS (
    SELECT 'Contributions – cash' AS SubCategory
    UNION ALL
    SELECT 'Contributions – non-monetary assets'
),
expected AS (
    SELECT
        cy.Council,
        cy.FinancialYear,
        ct.SubCategory
    FROM council_years cy
    CROSS JOIN contribution_types ct
)
SELECT
    e.Council,
    e.FinancialYear,
    e.SubCategory
FROM expected e
LEFT JOIN workspace.default.fact_financial f
    ON e.Council = f.Council
   AND e.FinancialYear = f.FinancialYear
   AND e.SubCategory = f.SubCategory
   AND f.Category = 'Revenue'
WHERE f.Council IS NULL
ORDER BY
    e.SubCategory,
    e.FinancialYear,
    e.Council;






SELECT
    IndicatorID,
    IndicatorName,
    YearsAvailable,
    ComparabilityStatus
FROM workspace.default.dim_indicator
WHERE LOWER(IndicatorName) LIKE '%operat%'
   OR LOWER(IndicatorName) LIKE '%surplus%'
   OR LOWER(IndicatorName) LIKE '%deficit%'
   OR LOWER(IndicatorName) LIKE '%revenue%'
   OR LOWER(IndicatorName) LIKE '%expense%'
ORDER BY IndicatorID;








SELECT
    p.FinancialYear,
    p.Council,
    p.IndicatorID,
    p.Result,
    s.Description
FROM workspace.default.fact_performance p
LEFT JOIN workspace.default.silver_performance s
    ON p.Council = s.Council
   AND p.FinancialYear = s.FinancialYear
   AND p.IndicatorID = s.ID
WHERE p.IndicatorID = 'OP1'
ORDER BY p.FinancialYear, p.Council
LIMIT 20;






SELECT
    FinancialYear,
    COUNT(*) AS TotalRecords,
    COUNT(DISTINCT Council) AS Councils,
    SUM(CASE WHEN Result IS NULL THEN 1 ELSE 0 END) AS MissingResults,
    MIN(Result) AS MinimumRatio,
    MAX(Result) AS MaximumRatio,
    SUM(CASE WHEN Result < 0 THEN 1 ELSE 0 END) AS DeficitRecords
FROM workspace.default.fact_performance
WHERE IndicatorID = 'OP1'
GROUP BY FinancialYear
ORDER BY FinancialYear;






SELECT
    Council,
    FinancialYear,
    IndicatorID,
    Result,
    CASE
        WHEN Result IS NULL THEN 'Missing result'
        WHEN Result < -1 THEN 'Extreme negative ratio'
    END AS ReviewFlag
FROM workspace.default.fact_performance
WHERE IndicatorID = 'OP1'
  AND (
      Result IS NULL
      OR Result < -1
  )
ORDER BY FinancialYear, Council;






CREATE OR REPLACE TABLE
workspace.default.gold_kpi_operating_sustainability
USING DELTA
AS
SELECT
    p.Council,
    p.FinancialYear,
    c.CouncilCategory,
    p.IndicatorID,
    p.Result AS AdjustedUnderlyingResultRatio,
    CASE
        WHEN p.Result IS NULL
            THEN 'Missing'
        WHEN p.Result < -1
            THEN 'Extreme negative - review'
        ELSE 'Reported'
    END AS DataQualityStatus
FROM workspace.default.fact_performance p
LEFT JOIN workspace.default.dim_council c
    ON p.Council = c.CouncilName
WHERE p.IndicatorID = 'OP1';






SELECT
    COUNT(*) AS TotalRecords,
    COUNT(DISTINCT Council) AS Councils,
    COUNT(DISTINCT FinancialYear) AS Years,
    SUM(CASE
        WHEN AdjustedUnderlyingResultRatio IS NULL
        THEN 1 ELSE 0
    END) AS MissingResults,
    SUM(CASE
        WHEN DataQualityStatus = 'Extreme negative - review'
        THEN 1 ELSE 0
    END) AS ExtremeResults,
    SUM(CASE
        WHEN CouncilCategory IS NULL
        THEN 1 ELSE 0
    END) AS MissingCategories
FROM workspace.default.gold_kpi_operating_sustainability;





SELECT
    FinancialYear,
    CouncilCategory,
    COUNT(*) AS TotalCouncils,
    COUNT(AdjustedUnderlyingResultRatio) AS ValidResults,
    ROUND(
        AVG(AdjustedUnderlyingResultRatio) * 100, 2
    ) AS AverageOP1Percent,
    ROUND(
        PERCENTILE_APPROX(
            AdjustedUnderlyingResultRatio, 0.5
        ) * 100, 2
    ) AS MedianOP1Percent,
    SUM(
        CASE
            WHEN AdjustedUnderlyingResultRatio < 0
            THEN 1 ELSE 0
        END
    ) AS CouncilsWithDeficit
FROM workspace.default.gold_kpi_operating_sustainability
GROUP BY FinancialYear, CouncilCategory
ORDER BY FinancialYear, CouncilCategory;





CREATE OR REPLACE TABLE
workspace.default.gold_kpi_peer_benchmarks
USING DELTA
AS
SELECT
    FinancialYear,
    CouncilCategory,
    COUNT(*) AS TotalCouncils,
    COUNT(AdjustedUnderlyingResultRatio) AS ValidResults,
    AVG(AdjustedUnderlyingResultRatio) AS AverageOP1Ratio,
    PERCENTILE_APPROX(
        AdjustedUnderlyingResultRatio, 0.5
    ) AS MedianOP1Ratio,
    SUM(
        CASE
            WHEN AdjustedUnderlyingResultRatio < 0
            THEN 1 ELSE 0
        END
    ) AS CouncilsWithDeficit
FROM workspace.default.gold_kpi_operating_sustainability
GROUP BY FinancialYear, CouncilCategory;





SELECT
    COUNT(*) AS TotalBenchmarkGroups,
    COUNT(DISTINCT FinancialYear) AS FinancialYears,
    COUNT(DISTINCT CouncilCategory) AS CouncilCategories,
    SUM(TotalCouncils) AS TotalCouncilObservations,
    SUM(ValidResults) AS TotalValidResults,
    SUM(CouncilsWithDeficit) AS TotalDeficitRecords,
    SUM(
        CASE
            WHEN MedianOP1Ratio IS NULL
            THEN 1 ELSE 0
        END
    ) AS MissingMedians
FROM workspace.default.gold_kpi_peer_benchmarks;





SELECT
    k.Council,
    k.FinancialYear,
    k.CouncilCategory,
    ROUND(
        k.AdjustedUnderlyingResultRatio * 100, 2
    ) AS CouncilOP1Percent,
    ROUND(
        b.MedianOP1Ratio * 100, 2
    ) AS PeerMedianPercent,
    ROUND(
        (
            k.AdjustedUnderlyingResultRatio
            - b.MedianOP1Ratio
        ) * 100, 2
    ) AS DifferencePercentagePoints,
    k.DataQualityStatus
FROM workspace.default.gold_kpi_operating_sustainability k
LEFT JOIN workspace.default.gold_kpi_peer_benchmarks b
    ON k.FinancialYear = b.FinancialYear
   AND k.CouncilCategory = b.CouncilCategory
ORDER BY
    k.FinancialYear,
    k.CouncilCategory,
    k.Council;






CREATE OR REPLACE TABLE
workspace.default.gold_kpi_council_comparison
USING DELTA
AS
SELECT
    k.Council,
    k.FinancialYear,
    k.CouncilCategory,
    k.IndicatorID,
    k.AdjustedUnderlyingResultRatio AS CouncilOP1Ratio,
    b.MedianOP1Ratio AS PeerMedianRatio,
    (
        k.AdjustedUnderlyingResultRatio
        - b.MedianOP1Ratio
    ) AS DifferenceRatio,
    k.DataQualityStatus
FROM workspace.default.gold_kpi_operating_sustainability k
LEFT JOIN workspace.default.gold_kpi_peer_benchmarks b
    ON k.FinancialYear = b.FinancialYear
   AND k.CouncilCategory = b.CouncilCategory;





SELECT
    COUNT(*) AS TotalRecords,
    COUNT(DISTINCT Council) AS Councils,
    COUNT(DISTINCT FinancialYear) AS Years,
    COUNT(CouncilOP1Ratio) AS ValidOP1Results,
    SUM(CASE
        WHEN CouncilOP1Ratio IS NULL
        THEN 1 ELSE 0
    END) AS MissingOP1Results,
    SUM(CASE
        WHEN PeerMedianRatio IS NULL
        THEN 1 ELSE 0
    END) AS MissingPeerMedians,
    SUM(CASE
        WHEN CouncilOP1Ratio IS NOT NULL
         AND DifferenceRatio IS NULL
        THEN 1 ELSE 0
    END) AS InvalidComparisons
FROM workspace.default.gold_kpi_council_comparison;





SELECT
    IndicatorID,
    IndicatorName,
    YearsAvailable,
    ComparabilityStatus
FROM workspace.default.dim_indicator
WHERE LOWER(IndicatorName) LIKE '%liquid%'
   OR LOWER(IndicatorName) LIKE '%asset%'
   OR LOWER(IndicatorName) LIKE '%liabilit%'
   OR LOWER(IndicatorName) LIKE '%debt%'
   OR LOWER(IndicatorName) LIKE '%loan%'
   OR LOWER(IndicatorName) LIKE '%renewal%'
   OR LOWER(IndicatorName) LIKE '%working capital%'
ORDER BY IndicatorID;





SELECT
    FinancialYear,
    COUNT(*) AS TotalRecords,
    COUNT(DISTINCT Council) AS Councils,
    SUM(CASE WHEN Result IS NULL
        THEN 1 ELSE 0 END) AS MissingResults,
    MIN(Result) AS MinimumValue,
    MAX(Result) AS MaximumValue,
    SUM(CASE WHEN Result < 0
        THEN 1 ELSE 0 END) AS NegativeValues
FROM workspace.default.fact_performance
WHERE IndicatorID = 'L1'
GROUP BY FinancialYear
ORDER BY FinancialYear;



SELECT
    p.Council,
    p.FinancialYear,
    p.Result,
    s.Description
FROM workspace.default.fact_performance p
LEFT JOIN workspace.default.silver_performance s
    ON p.Council = s.Council
   AND p.FinancialYear = s.FinancialYear
   AND p.IndicatorID = s.ID
WHERE p.IndicatorID = 'L1'
  AND (
      p.Result IS NULL
      OR p.Result > 10
  )
ORDER BY p.FinancialYear, p.Council;





CREATE OR REPLACE TABLE
workspace.default.gold_kpi_liquidity
USING DELTA
AS
SELECT
    p.Council,
    p.FinancialYear,
    c.CouncilCategory,
    p.IndicatorID,
    p.Result AS CurrentAssetsToLiabilitiesRatio,
    CASE
        WHEN p.Result IS NULL
            THEN 'Missing'
        WHEN p.Result > 10
            THEN 'High ratio - review'
        WHEN p.Result < 0
            THEN 'Negative ratio - review'
        ELSE 'Reported'
    END AS DataQualityStatus
FROM workspace.default.fact_performance p
LEFT JOIN workspace.default.dim_council c
    ON p.Council = c.CouncilName
WHERE p.IndicatorID = 'L1';







SELECT
    COUNT(*) AS TotalRecords,
    COUNT(DISTINCT Council) AS Councils,
    COUNT(DISTINCT FinancialYear) AS Years,
    COUNT(CurrentAssetsToLiabilitiesRatio) AS ValidResults,
    SUM(CASE
        WHEN CurrentAssetsToLiabilitiesRatio IS NULL
        THEN 1 ELSE 0
    END) AS MissingResults,
    SUM(CASE
        WHEN DataQualityStatus = 'High ratio - review'
        THEN 1 ELSE 0
    END) AS HighRatioFlags,
    SUM(CASE
        WHEN CouncilCategory IS NULL
        THEN 1 ELSE 0
    END) AS MissingCategories
FROM workspace.default.gold_kpi_liquidity;




SELECT
    FinancialYear,
    COUNT(*) AS TotalRecords,
    COUNT(DISTINCT Council) AS Councils,
    SUM(
        CASE WHEN Result IS NULL
        THEN 1 ELSE 0 END
    ) AS MissingResults,
    MIN(Result) AS MinimumValue,
    MAX(Result) AS MaximumValue,
    SUM(
        CASE WHEN Result < 0
        THEN 1 ELSE 0 END
    ) AS NegativeValues
FROM workspace.default.fact_performance
WHERE IndicatorID = 'O4'
GROUP BY FinancialYear
ORDER BY FinancialYear;



SELECT
    p.Council,
    p.FinancialYear,
    p.Result,
    s.Description
FROM workspace.default.fact_performance p
LEFT JOIN workspace.default.silver_performance s
    ON p.Council = s.Council
   AND p.FinancialYear = s.FinancialYear
   AND p.IndicatorID = s.ID
WHERE p.IndicatorID = 'O4'
  AND (
      p.Result IS NULL
      OR p.Result > 1
  )
ORDER BY p.FinancialYear, p.Council;






CREATE OR REPLACE TABLE
workspace.default.gold_financial_kpis
USING DELTA
AS
SELECT
    p.Council,
    p.FinancialYear,
    c.CouncilCategory,
    p.IndicatorID,
    i.IndicatorName,
    p.Result AS KPIValue,
    CASE
        WHEN p.Result IS NULL THEN 'Missing'
        WHEN p.Result < 0
             AND p.IndicatorID IN ('L1', 'O4', 'O5')
             THEN 'Negative - review'
        ELSE 'Reported'
    END AS DataQualityStatus
FROM workspace.default.fact_performance p
LEFT JOIN workspace.default.dim_council c
    ON p.Council = c.CouncilName
LEFT JOIN workspace.default.dim_indicator i
    ON p.IndicatorID = i.IndicatorID
WHERE p.IndicatorID IN ('OP1', 'L1', 'O4', 'O5');




SELECT
    Council,
    FinancialYear,
    CouncilCategory,
    IndicatorID,
    KPIValue,
    PERCENTILE_APPROX(KPIValue, 0.5)
        OVER (
            PARTITION BY
                FinancialYear,
                CouncilCategory,
                IndicatorID
        ) AS PeerMedian
FROM workspace.default.gold_financial_kpis;






SELECT
    IndicatorID,
    COUNT(*) AS TotalRecords,
    COUNT(DISTINCT Council) AS Councils,
    COUNT(DISTINCT FinancialYear) AS Years,
    COUNT(KPIValue) AS ValidResults,
    SUM(CASE WHEN KPIValue IS NULL
        THEN 1 ELSE 0 END) AS MissingResults,
    SUM(CASE WHEN CouncilCategory IS NULL
        THEN 1 ELSE 0 END) AS MissingCategories
FROM workspace.default.gold_financial_kpis
GROUP BY IndicatorID
ORDER BY IndicatorID;





CREATE OR REPLACE TABLE
workspace.default.gold_financial_kpi_comparison
USING DELTA
AS
SELECT
    Council,
    FinancialYear,
    CouncilCategory,
    IndicatorID,
    IndicatorName,
    KPIValue,
    PERCENTILE_APPROX(KPIValue, 0.5)
        OVER (
            PARTITION BY
                FinancialYear,
                CouncilCategory,
                IndicatorID
        ) AS PeerMedian,
    DataQualityStatus
FROM workspace.default.gold_financial_kpis;




SELECT
    COUNT(*) AS TotalRecords,
    COUNT(DISTINCT IndicatorID) AS Indicators,
    COUNT(DISTINCT Council) AS Councils,
    COUNT(DISTINCT FinancialYear) AS Years,
    COUNT(KPIValue) AS ValidResults,
    SUM(CASE
        WHEN KPIValue IS NULL THEN 1 ELSE 0
    END) AS MissingResults,
    SUM(CASE
        WHEN PeerMedian IS NULL THEN 1 ELSE 0
    END) AS MissingPeerMedians,
    SUM(CASE
        WHEN CouncilCategory IS NULL THEN 1 ELSE 0
    END) AS MissingCategories
FROM workspace.default.gold_financial_kpi_comparison;




SELECT
    FinancialYear,
    Description,
    COUNT(*) AS Records,
    MIN(Result) AS MinimumValue,
    MAX(Result) AS MaximumValue
FROM workspace.default.silver_performance
WHERE ID = 'O5'
GROUP BY FinancialYear, Description
ORDER BY FinancialYear, Description;





SELECT
    Council,
    FinancialYear,
    Result AS AssetRenewalRatio,
    CASE
        WHEN Result IS NULL THEN 'Missing'
        WHEN Result > 3 THEN 'High ratio - review'
        ELSE 'Reported'
    END AS ReviewStatus
FROM workspace.default.fact_performance
WHERE IndicatorID = 'O5'
  AND (
      Result IS NULL
      OR Result > 3
  )
ORDER BY FinancialYear, Council;




SELECT
    Council,
    FinancialYear,
    IndicatorID,
    COUNT(*) AS DuplicateCount
FROM workspace.default.gold_financial_kpi_comparison
GROUP BY
    Council,
    FinancialYear,
    IndicatorID
HAVING COUNT(*) > 1;





SELECT *
FROM workspace.default.gold_financial_kpi_comparison
WHERE FinancialYear IN (
    '2020-21',
    '2021-22',
    '2022-23'
)
ORDER BY FinancialYear, Council, IndicatorID;



SELECT *
FROM workspace.default.gold_financial_kpi_comparison
WHERE FinancialYear IN (
    '2023-24',
    '2024-25'
)
ORDER BY FinancialYear, Council, IndicatorID;






