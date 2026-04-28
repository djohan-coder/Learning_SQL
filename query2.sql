# HARI 18
-- ============================================================
-- MODUL 1: Cohort analysis dasar
-- ============================================================

WITH first_order AS (
    SELECT
        customer_id,
        DATE_FORMAT(MIN(tanggal_order), '%Y-%m') AS cohort_month
    FROM orders
    WHERE status = 'selesai'
    GROUP BY customer_id
),
order_activity AS (
    SELECT
        customer_id,
        DATE_FORMAT(tanggal_order, '%Y-%m') AS activity_month
    FROM orders
    WHERE status = 'selesai'
    GROUP BY customer_id, activity_month
),
cohort_data AS (
    SELECT
        f.cohort_month,
        f.customer_id,
        TIMESTAMPDIFF(MONTH,
            STR_TO_DATE(CONCAT(f.cohort_month, '-01'), '%Y-%m-%d'),
            STR_TO_DATE(CONCAT(oa.activity_month, '-01'), '%Y-%m-%d')
        ) AS month_number
    FROM first_order f
    JOIN order_activity oa ON f.customer_id = oa.customer_id
    WHERE TIMESTAMPDIFF(MONTH,
        STR_TO_DATE(CONCAT(f.cohort_month, '-01'), '%Y-%m-%d'),
        STR_TO_DATE(CONCAT(oa.activity_month, '-01'), '%Y-%m-%d')
    ) BETWEEN 0 AND 2
),
cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM first_order
    GROUP BY cohort_month
)
SELECT
    cd.cohort_month,
    MAX(cs.cohort_size)              AS cohort_size,
    cd.month_number,
    COUNT(DISTINCT cd.customer_id)   AS active_customers,
    ROUND(
        COUNT(DISTINCT cd.customer_id) * 100.0 / MAX(cs.cohort_size),
    2) AS retention_pct
FROM cohort_data cd
JOIN cohort_size cs ON cd.cohort_month = cs.cohort_month
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
			DATE_FORMAT(oa.activity_month, '%Y%m'),
            DATE_FORMAT(f.cohort_month, '%Y%m')
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

-- ============================================================
-- MODUL 3: Buat analisis Revenue Cohort
-- ============================================================

WITH first_order AS (
	-- 1 Step: Identifikasi bulan pertama order setiap customer (cohort)
    SELECT
		customer_id,
        DATE_FORMAT(MIN(tanggal_order), '%Y-%m') AS	cohort_month
	FROM orders
    WHERE status = 'selesai'
    GROUP BY customer_id
),
order_activity AS (
	-- 2 Step: Mapping aktivitas bulanan + revenue per customer
    SELECT
		customer_id,
        DATE_FORMAT(tanggal_order, '%Y-%m') AS activity_month,
        SUM(total_harga) AS monthly_revenue
	FROM orders
    WHERE status = 'selesai'
    GROUP BY customer_id, activity_month
),
cohort_data AS (
	-- 3 Step: Hitung selisih bulan + bawa revenue
    SELECT 
        f.cohort_month,
        f.customer_id,
        PERIOD_DIFF(
            DATE_FORMAT(oa.activity_month, '%Y%m'),
            DATE_FORMAT(f.cohort_month, '%Y%m')
        ) AS month_number,
        oa.monthly_revenue
    FROM first_order f
    JOIN order_activity oa ON f.customer_id = oa.customer_id
    WHERE PERIOD_DIFF(
        DATE_FORMAT(oa.activity_month, '%Y%m'),
        DATE_FORMAT(f.cohort_month, '%Y%m')
    ) BETWEEN 0 AND 2  -- 🔍 Fokus 3 bulan pertama
),
cohort_baseline AS (
	-- 4 Step: Hitung baseline month-0 per cohort (denominator untuk retention)
    SELECT
		cohort_month,
        COUNT(DISTINCT customer_id) AS baseline_customers,
        SUM(monthly_revenue) AS baseline_revenue
	FROM cohort_data
    WHERE month_number = 0
    GROUP BY cohort_month
),
cohort_revenue_agg AS (
	-- 5 Step: Aggregasi metrik per (cohort, month_number)
    SELECT
		cd.cohort_month,
        cd.month_number,
        COUNT(DISTINCT cd.customer_id) AS active_customers,
        ROUND(SUM(cd.monthly_revenue), 2) AS total_revenue,
        ROUND(AVG(cd.monthly_revenue), 2) AS avg_revenue_per_customer
	FROM cohort_data AS cd
    GROUP BY cd.cohort_month, cd.month_number
)
-- Final: join dengan baseline + Hitung revenue_retentation_pct
SELECT
	cra.cohort_month,
    cra.month_number,
    cra.active_customers,
    cra.total_revenue,
    cra.avg_revenue_per_customer,
    cb.baseline_revenue,
    CASE
		WHEN cb.baseline_revenue IS NULL OR cb.baseline_revenue = 0 THEN NULL
        ELSE ROUND(cra.total_revenue * 100.0 / cb.baseline_revenue, 2)
	END AS revenue_retention_pct
FROM cohort_revenue_agg AS cra
LEFT JOIN cohort_baseline cb ON cra.cohort_month = cb.cohort_month
ORDER BY cra.cohort_month, cra.month_number;

-- ============================================================
-- MODUL 4: Buat analisis Churn Prediction
-- ============================================================

WITH customer_metrics AS (
    -- 1️ Hitung metrik RFM dasar per customer
    SELECT
        c.customer_id,
        c.nama,
        DATEDIFF(CURDATE(), MAX(o.tanggal_order)) AS recency,
        COUNT(o.order_id) AS frequency,
        COALESCE(SUM(o.total_harga), 0) AS monetary
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.status = 'selesai'
    GROUP BY c.customer_id, c.nama
),
avg_benchmark AS (
    -- 2️ Hitung rata-rata monetary seluruh customer aktif
    SELECT AVG(monetary) AS avg_monetary
    FROM customer_metrics
),
churn_candidates AS (
    -- 3️ Filter sesuai kriteria churn: recency > 30, freq >= 1, monetary > avg
    SELECT
        cm.*,
        ab.avg_monetary
    FROM customer_metrics cm
    CROSS JOIN avg_benchmark ab
    WHERE cm.recency > 30
      AND cm.frequency >= 1
      AND cm.monetary > ab.avg_monetary
)
-- 4️ Scoring 1-3 & Output Final
SELECT
    nama,
    recency,
    frequency,
    ROUND(monetary, 2) AS monetary,
    CASE
        WHEN recency > 90 THEN 3
        WHEN recency > 60 THEN 2
        ELSE 1
    END AS churn_risk_score,
    CASE
        WHEN recency > 90 THEN 'Tinggi'
        WHEN recency > 60 THEN 'Sedang'
        ELSE 'Rendah'
    END AS risk_level
FROM churn_candidates
ORDER BY churn_risk_score DESC, monetary DESC;

-- ============================================================
-- MODUL 5: Buat laporan Customer Lifetime Value (CLV) Projection
-- ============================================================

WITH first_order AS (
    -- 1️ Step 1: Identifikasi cohort month (bulan pertama order) per customer
    SELECT 
        customer_id,
        DATE_FORMAT(MIN(tanggal_order), '%Y-%m') AS cohort_month
    FROM orders
    WHERE status = 'selesai'
    GROUP BY customer_id
),
monthly_revenue AS (
    -- 2️ Step 2: Hitung revenue per customer per bulan
    SELECT 
        customer_id,
        DATE_FORMAT(tanggal_order, '%Y-%m') AS activity_month,
        SUM(total_harga) AS monthly_revenue
    FROM orders
    WHERE status = 'selesai'
    GROUP BY customer_id, activity_month
),
cohort_monthly_data AS (
    -- 3️ Step 3: Gabungkan cohort info dengan aktivitas bulanan + hitung month_number
    SELECT 
        f.cohort_month,
        f.customer_id,
        oa.activity_month,
        oa.monthly_revenue,
        PERIOD_DIFF(
            DATE_FORMAT(oa.activity_month, '%Y%m'),
            DATE_FORMAT(f.cohort_month, '%Y%m')
        ) AS month_number
    FROM first_order f
    JOIN monthly_revenue oa ON f.customer_id = oa.customer_id
),
cohort_aggregates AS (
    -- 4️ Step 4: Agregasi metrik per cohort
    SELECT 
        cohort_month,
        SUM(CASE WHEN month_number = 0 THEN monthly_revenue ELSE 0 END) AS revenue_month_0,
        COUNT(DISTINCT CASE WHEN monthly_revenue > 0 THEN activity_month END) AS active_months,
        SUM(monthly_revenue) AS total_revenue_all_months,
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM cohort_monthly_data
    GROUP BY cohort_month
),
cohort_clv_calc AS (
    -- 5️ Step 5: Hitung avg monthly revenue & proyeksi CLV 6 bulan
    SELECT 
        cohort_month,
        cohort_size,
        revenue_month_0,
        total_revenue_all_months,
        active_months,
        ROUND(total_revenue_all_months / NULLIF(active_months, 0), 2) AS avg_monthly_revenue,
        ROUND((total_revenue_all_months / NULLIF(active_months, 0)) * 6, 2) AS clv_projection_6month
    FROM cohort_aggregates
),
clv_benchmark AS (
    -- 6️ Step 6: Hitung rata-rata CLV semua cohort untuk benchmarking
    SELECT AVG(clv_projection_6month) AS avg_clv_all_cohorts
    FROM cohort_clv_calc
)
-- Final: Tambahkan label berdasarkan perbandingan dengan rata-rata global
SELECT 
    c.cohort_month,
    c.cohort_size,
    c.revenue_month_0,
    c.active_months,
    c.avg_monthly_revenue,
    c.clv_projection_6month,
    ROUND(b.avg_clv_all_cohorts, 2) AS benchmark_avg_clv,
    CASE 
        WHEN c.clv_projection_6month > b.avg_clv_all_cohorts * 1.2 THEN 'High Value Cohort'
        WHEN c.clv_projection_6month < b.avg_clv_all_cohorts * 0.8 THEN 'Low Value Cohort'
        ELSE 'Medium Value Cohort'
    END AS cohort_value_label
FROM cohort_clv_calc c
CROSS JOIN clv_benchmark b
ORDER BY c.clv_projection_6month DESC;