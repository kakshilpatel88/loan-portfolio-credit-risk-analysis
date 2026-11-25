-- LOAN PORTFOLIO & CREDIT RISK ANALYSIS
-- BigQuery Standard SQL
-- STEP 1: Create a dataset named loan_portfolio in your BigQuery project.
-- STEP 2: Upload data/cleaned/loan_portfolio_cleaned.csv as table loans_cleaned.
-- STEP 3: Replace YOUR_PROJECT_ID below with your Google Cloud project ID.
-- Interest_Rate and DTI are decimals (e.g. 0.15 = 15%).

-- 1. Executive KPI summary
SELECT COUNT(DISTINCT Loan_ID) AS total_loans,
       SUM(Loan_Amount) AS total_originated,
       AVG(Loan_Amount) AS average_loan_amount,
       SUM(Outstanding_Balance) AS total_outstanding_balance,
       SUM(Default_Flag) AS defaulted_loans,
       SAFE_DIVIDE(SUM(Default_Flag), COUNT(*)) AS default_rate,
       SUM(NPL_Flag) AS npl_loans,
       SAFE_DIVIDE(SUM(NPL_Flag), COUNT(*)) AS npl_rate,
       AVG(Interest_Rate) AS average_interest_rate,
       AVG(DTI) AS average_dti
FROM `YOUR_PROJECT_ID.loan_portfolio.loans_cleaned`;

-- 2. Loan origination trends by year
SELECT Issue_Year, COUNT(*) AS loan_count,
       SUM(Loan_Amount) AS total_originated,
       SUM(Outstanding_Balance) AS outstanding_balance,
       SUM(Default_Flag) AS defaults,
       SAFE_DIVIDE(SUM(Default_Flag), COUNT(*)) AS default_rate
FROM `YOUR_PROJECT_ID.loan_portfolio.loans_cleaned`
GROUP BY Issue_Year ORDER BY Issue_Year;

-- 3. Risk and performance by loan grade
SELECT Grade, COUNT(*) AS loan_count,
       SUM(Loan_Amount) AS total_originated,
       AVG(Interest_Rate) AS average_interest_rate,
       SUM(Default_Flag) AS defaults,
       SAFE_DIVIDE(SUM(Default_Flag), COUNT(*)) AS default_rate,
       SUM(Outstanding_Balance) AS outstanding_balance
FROM `YOUR_PROJECT_ID.loan_portfolio.loans_cleaned`
GROUP BY Grade ORDER BY Grade;

-- 4. Loan purpose analysis
SELECT Purpose, COUNT(*) AS loan_count,
       SUM(Loan_Amount) AS total_originated,
       AVG(Loan_Amount) AS average_loan_amount,
       SUM(Outstanding_Balance) AS outstanding_balance
FROM `YOUR_PROJECT_ID.loan_portfolio.loans_cleaned`
GROUP BY Purpose ORDER BY total_originated DESC;

-- 5. Loan status and non-performing loan analysis
SELECT Loan_Status, COUNT(*) AS loan_count,
       SUM(Outstanding_Balance) AS outstanding_balance,
       SUM(Default_Flag) AS defaults, SUM(NPL_Flag) AS npl_loans
FROM `YOUR_PROJECT_ID.loan_portfolio.loans_cleaned`
GROUP BY Loan_Status ORDER BY loan_count DESC;

-- 6. Income band and DTI analysis
SELECT Income_Band, COUNT(*) AS loan_count, AVG(DTI) AS average_dti,
       SUM(Default_Flag) AS defaults,
       SAFE_DIVIDE(SUM(Default_Flag), COUNT(*)) AS default_rate,
       SUM(Outstanding_Balance) AS outstanding_balance
FROM `YOUR_PROJECT_ID.loan_portfolio.loans_cleaned`
GROUP BY Income_Band ORDER BY loan_count DESC;

-- 7. State-level portfolio analysis
SELECT State, COUNT(*) AS loan_count,
       SUM(Loan_Amount) AS total_originated,
       SUM(Outstanding_Balance) AS outstanding_balance,
       SUM(Default_Flag) AS defaults,
       SAFE_DIVIDE(SUM(Default_Flag), COUNT(*)) AS default_rate
FROM `YOUR_PROJECT_ID.loan_portfolio.loans_cleaned`
GROUP BY State ORDER BY outstanding_balance DESC;

-- 8. Loan term analysis
SELECT Term_Months, COUNT(*) AS loan_count,
       AVG(Interest_Rate) AS average_interest_rate,
       SUM(Default_Flag) AS defaults,
       SAFE_DIVIDE(SUM(Default_Flag), COUNT(*)) AS default_rate
FROM `YOUR_PROJECT_ID.loan_portfolio.loans_cleaned`
GROUP BY Term_Months ORDER BY Term_Months;

-- 9. Data quality: duplicate loan IDs (should return no rows)
SELECT Loan_ID, COUNT(*) AS row_count
FROM `YOUR_PROJECT_ID.loan_portfolio.loans_cleaned`
GROUP BY Loan_ID HAVING COUNT(*) > 1;

-- 10. Data quality: invalid or missing values (should return no rows)
SELECT *
FROM `YOUR_PROJECT_ID.loan_portfolio.loans_cleaned`
WHERE Loan_ID IS NULL OR Issue_Date IS NULL OR Loan_Amount <= 0
   OR Term_Months <= 0 OR Interest_Rate < 0 OR Interest_Rate > 1
   OR DTI < 0 OR DTI > 1 OR Default_Flag NOT IN (0,1)
   OR NPL_Flag NOT IN (0,1);

-- 11. Cross-check status against flags; review any returned rows against source definitions
SELECT Loan_ID, Loan_Status, Default_Flag, NPL_Flag
FROM `YOUR_PROJECT_ID.loan_portfolio.loans_cleaned`
WHERE (Loan_Status = 'Charged Off' AND Default_Flag != 1)
   OR (Loan_Status = 'Late (31-120)' AND NPL_Flag != 1);
