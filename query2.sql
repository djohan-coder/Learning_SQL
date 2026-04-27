# HARI 18
-- ============================================================
-- MODUL 1: Cohort analysis dasar
-- ============================================================

WITH first_order AS (
	-- Step 1: Identifikasi bulan pertama order setiap customer (cohort)
    SELECT
		customer_id,
        DATE_FORMAT(MIN(tanggal_order), '%Y-%m') AS cohort_month
	FROM orders
    WHERE status = 'selesai'
    GROUP BY customer_id
),
order_activity AS (
	-- Step 2: Mapping aktivitas bulanan setiap customer
    SELECT
		customer_id,
        DATE_FORMAT(tanggal_order, '%Y-%m') AS activity_month
	FROM orders
    WHERE status = 'selesai'
    GROUP BY customer_id, activity_month
),
cohort_data AS (
	-- Step 3: Hitung selisih bulan (period index: 0, 1, 2, ..)
    SELECT
		f.cohort_month,
        f.customer_id,
        PERIOD_DIFF(
			DATE_FORMAT(oa.activity_month, '%Y/m'),
            DATE_FORMAT(f.cohort_month, '%Y/m')
		) AS month_number
	FROM first_order AS f
    JOIN order_activity AS oa ON f.customer_id = oa.customer_id
    WHERE PERIOD_DIFF(
		DATE_FORMAT(oa.activity_month, '%Y/m'),
        DATE_FORMAT(f.cohort_month, '%Y/m')
	) BETWEEN 0 AND 2 -- filter hanya bulan ke-0, ke-1, ke-2
),
cohort_size AS (
	-- Step 4: Hitung total customer awal per cohort (denominator)
    SELECT
		cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_size
	FROM first_order
    GROUP BY cohort_month
)
-- Step 5: Final agggregation + retrntion calculation
SELECT
	cd.cohort_month,
    MAX(cs.cohort_size) AS cohort_size,
    cd.month_number,
    COUNT(DISTINCT cd.customer_id) AS active_customers,
    ROUND(
		COUNT(DISTINCT cd.customer_id) * 100.0 / MAX(cs.cohort_size),
        2
	) AS retention_pct
FROM cohort_data AS cd
JOIN cohort_size AS cs ON cd.cohort_month = cs.cohort_month
GROUP BY cd.cohort_month, cd.month_number
ORDER BY cd.cohort_month, cd.month_number;

--  --------------------------------------------------------

WITH first_order AS (
	-- Step 1: Identifikasi bulan pertama order setiap customer (cohort)
    SELECT
		customer_id,
        DATE_FORMAT(MIN(tanggal_order), '%Y-%m') AS cohort_month
	FROM orders
    WHERE status = 'selesai'
    GROUP BY customer_id
),
order_activity AS (
	-- Step 2: Mapping aktivitas bulanan setiap customer
    SELECT
		customer_id,
        DATE_FORMAT(tanggal_order, '%Y-%m') AS activity_month
	FROM orders
    WHERE status = 'selesai'
    GROUP BY customer_id, activity_month
),
cohort_data AS (
	-- Step 3: Hitung selisih bulan (period index: 0, 1, 2, ..)
    SELECT
		f.cohort_month,
        f.customer_id,
            TIMESTAMPDIFF(MONTH, 
    STR_TO_DATE(CONCAT(f.cohort_month, '-01'), '%Y-%m-%d'),
    STR_TO_DATE(CONCAT(oa.activity_month, '-01'), '%Y-%m-%d')
		) AS month_number
	FROM first_order AS f
    JOIN order_activity AS oa ON f.customer_id = oa.customer_id
    WHERE PERIOD_DIFF(
		DATE_FORMAT(oa.activity_month, '%Y/m'),
        DATE_FORMAT(f.cohort_month, '%Y/m')
	) BETWEEN 0 AND 2 -- filter hanya bulan ke-0, ke-1, ke-2
),
cohort_size AS (
	-- Step 4: Hitung total customer awal per cohort (denominator)
    SELECT
		cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_size
	FROM first_order
    GROUP BY cohort_month
)
-- Step 5: Final agggregation + retrntion calculation
SELECT
	cd.cohort_month,
    MAX(cs.cohort_size) AS cohort_size,
    cd.month_number,
    COUNT(DISTINCT cd.customer_id) AS active_customers,
    ROUND(
		COUNT(DISTINCT cd.customer_id) * 100.0 / MAX(cs.cohort_size),
        2
	) AS retention_pct
FROM cohort_data AS cd
JOIN cohort_size AS cs ON cd.cohort_month = cs.cohort_month
GROUP BY cd.cohort_month, cd.month_number
ORDER BY cd.cohort_month, cd.month_number;

-- ============================================================
-- MODUL 2: Cohort analysis dengan Pivot Horizontal
-- ============================================================

WITH first_order AS (
	-- 1 Step: Identifikasi bulan pertama order setiap customer (cohort)
    SELECT
		customer_id,
        DATE_FORMAT(MIN(tanggal_order), '%Y-%m') AS cohort_month
	FROM orders
    WHERE status = 'selesai'
    GROUP BY customer_id
),
order_activity AS (
	-- 2 Step: Mapping aktivitas bulanan setiap customer
    SELECT
		customer_id,
        DATE_FORMAT(tanggal_order, '%Y-%m') AS activity_month
	FROM orders
    WHERE status = 'selesai'
    GROUP BY customer_id, activity_month
),
cohort_data AS (
	-- 3 Step: Hitung selisih bulan (periode index: 0, 1, 2)
    SELECT
		f.cohort_month,
        f.customer_id,
        PERIOD_DIFF(
			DATE_FORMAT(oa.activity_month, '%Y/%m'),
            DATE_FORMAT(f.cohort_month, '%Y/%m')
		) AS month_number
	FROM first_order AS f
    JOIN order_activity AS oa ON f.customer_id = oa.customer_id
    WHERE PERIOD_DIFF(
		DATE_FORMAT(oa.activity_month, '%Y/%m'),
        DATE_FORMAT(f.cohort_month, '%Y/%m')
	) BETWEEN 0 AND 2
),
cohort_size AS (
	-- 4 Step: Hitung total customer awal per cohort
    SELECT
		cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_size
	FROM first_order
    GROUP BY cohort_month
),
cohort_retention AS (
	-- 5 Step: Hitung retensi per (cohort, month_number)
    SELECT
		cd.cohort_month,
        MAX(cs.cohort_size) AS cohort_size,
        cd.month_number,
        COUNT(DISTINCT cd.customer_id) AS active_customers,
        ROUND(
			COUNT(DISTINCT cd.customer_id) * 100.0 / MAX(cs.cohort_size),
            2
		) AS retention_pct
	FROM cohort_data AS cd
    JOIN cohort_size AS cs ON cd.cohort_month = cs.cohort_month
    GROUP BY cd.cohort_month, cd.month_number
)
-- PIVOT: ubah vertikal ke horizontal dengan MAX(CASE WHEN)
SELECT
	cohort_month,
    MAX(cohort_size) AS cohort_size,
    CONCAT(ROUND(MAX(CASE WHEN month_number = 0 THEN retention_pct END), 1), '%') AS M0,
    CONCAT(ROUND(MAX(CASE WHEN month_number = 1 THEN retention_pct END), 1), '%') AS M1,
    CONCAT(ROUND(MAX(CASE WHEN month_number = 2 THEN retention_pct END), 1), '%') AS M2
FROM cohort_retention
GROUP BY cohort_month
ORDER BY cohort_month DESC;