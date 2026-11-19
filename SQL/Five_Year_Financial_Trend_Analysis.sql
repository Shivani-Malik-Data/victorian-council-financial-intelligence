
-- =====================================================
-- FIVE-YEAR FINANCIAL ENDPOINT ANALYSIS
-- Victorian Local Government | 2020-21 to 2024-25
-- =====================================================

CREATE OR REPLACE TABLE
workspace.default.gold_council_financial_trends AS

WITH yearly_kpis AS (

    SELECT
        Council,
        CouncilCategory,
        IndicatorID,
        IndicatorName,

        MAX(
            CASE
                WHEN FinancialYear = '2020-21'
                THEN KPIValue
            END
        ) AS StartValue,

        MAX(
            CASE
                WHEN FinancialYear = '2024-25'
                THEN KPIValue
            END
        ) AS EndValue,

        COUNT(KPIValue) AS ReportedYears

    FROM workspace.default.gold_financial_kpi_comparison_validated

    GROUP BY
        Council,
        CouncilCategory,
        IndicatorID,
        IndicatorName
),

financial_trends AS (

    SELECT
        Council,
        CouncilCategory,
        IndicatorID,
        IndicatorName,

        ROUND(StartValue, 4) AS StartValue,
        ROUND(EndValue, 4) AS EndValue,

        ROUND(EndValue - StartValue, 4)
            AS FiveYearChange,

        ReportedYears,

        CASE
            WHEN ReportedYears = 5
                THEN 'Complete'

            ELSE 'Incomplete'
        END AS DataCompleteness,

        CASE
            WHEN StartValue IS NULL
              OR EndValue IS NULL
                THEN 'Insufficient Data'

            WHEN ABS(EndValue - StartValue) < 0.00005
                THEN 'Stable'

            WHEN IndicatorID IN ('OP1', 'L1', 'O5')
              AND EndValue < StartValue
                THEN 'Deteriorating'

            WHEN IndicatorID = 'O4'
              AND EndValue > StartValue
                THEN 'Deteriorating'

            ELSE 'Improving'

        END AS TrendDirection

    FROM yearly_kpis
)

SELECT *
FROM financial_trends;


-- =====================================================
-- VALIDATION 1: ROW COUNT AND UNIQUENESS
-- =====================================================

SELECT
    COUNT(*) AS TotalRows,

    COUNT(DISTINCT CONCAT(Council, '|', IndicatorID))
        AS UniqueCouncilIndicators,

    COUNT(*) -
    COUNT(DISTINCT CONCAT(Council, '|', IndicatorID))
        AS DuplicateRows

FROM workspace.default.gold_council_financial_trends;


-- =====================================================
-- VALIDATION 2: DATA COMPLETENESS
-- =====================================================

SELECT
    DataCompleteness,
    COUNT(*) AS RecordCount

FROM workspace.default.gold_council_financial_trends

GROUP BY DataCompleteness;


-- =====================================================
-- VALIDATION 3: TREND CLASSIFICATIONS
-- =====================================================

SELECT
    IndicatorID,
    TrendDirection,
    COUNT(*) AS CouncilCount

FROM workspace.default.gold_council_financial_trends

GROUP BY IndicatorID, TrendDirection

ORDER BY IndicatorID, TrendDirection;


-- =====================================================
-- VALIDATION 4: TOWONG SHIRE
-- =====================================================

SELECT
    Council,
    IndicatorID,
    StartValue,
    EndValue,
    FiveYearChange,
    ReportedYears,
    DataCompleteness,
    TrendDirection

FROM workspace.default.gold_council_financial_trends

WHERE Council = 'Towong Shire'

ORDER BY IndicatorID;
