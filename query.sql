# HARI 10
# 1
WITH customer_totals AS (
	SELECT
		c.customer_id,
        c.nama AS nama_customer,
        SUM(o.total_harga)	AS total_belanja
	FROM customers AS c
    JOIN orders  AS o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.nama
),
average_spending AS (
	SELECT
		AVG(total_belanja) AS rata_rata_global
        FROM customer_totals
)
SELECT
	ct.nama_customer,
    ct.total_belanja
FROM customer_totals AS ct
CROSS JOIN average_spending AS av
WHERE ct.total_belanja > av.rata_rata_global
ORDER BY ct.total_belanja DESC ;

# 2
WITH produk_terlaris AS (
	SELECT
		p.nama_produk,
        p.kategori,
		COALESCE(SUM(oi.quantity), 0) AS total_qty_terjual,
        COALESCE(SUM(oi.quantity * oi.harga_satuan), 0) AS total_revenue
	FROM products AS p
LEFT JOIN order_items AS oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.nama_produk, p.kategori
)
SELECT
	nama_produk,
    kategori,
    total_qty_terjual,
    ROUND(total_revenue, 2) AS total_revenue,
    RANK() OVER(ORDER BY total_revenue DESC) AS revenue_rank
FROM produk_terlaris
WHERE total_revenue > (SELECT AVG(total_revenue) FROM produk_terlaris)
ORDER BY revenue_rank;

# 3
WITH penjualan_harian AS (
	SELECT
		tanggal_order,
        SUM(total_harga) AS total_revenue
	FROM orders
    WHERE status = 'selesai'
    GROUP BY tanggal_order
),
penjualan_dengan_lag AS (
	SELECT
		tanggal_order,
        total_revenue,
		LAG(total_revenue, 1) OVER (ORDER BY tanggal_order) AS revenue_hari_sebelumnya
	FROM penjualan_harian
),
analisis_tren AS (
	SELECT
		tanggal_order,
        total_revenue,
        revenue_hari_sebelumnya,
        CASE
			WHEN revenue_hari_sebelumnya IS NULL THEN 'Data Awal'
            WHEN total_revenue > revenue_hari_sebelumnya THEN 'Naik'
            WHEN total_revenue < revenue_hari_sebelumnya THEN 'Turun'
            ELSE 'Sama'
		END AS tren
	FROM penjualan_dengan_lag
)
SELECT *
FROM analisis_tren
ORDER BY tanggal_order;

# 4
WITH total_per_customer AS (
	SELECT
		c.customer_id,
        c.nama,
        c.kota,
        COALESCE(SUM(o.total_harga), 0) AS total_belanja,
        COUNT(o.order_id) AS jumlah_order
	FROM customers AS c
    LEFT JOIN orders AS o ON c.customer_id = o.customer_id
		AND o.status = 'selesai'
	GROUP BY c.customer_id, c.nama, c.kota
),
dengan_rangking AS (
	SELECT
		customer_id,
        nama,
        kota,
        ROUND(total_belanja, 2) AS total_belanja, jumlah_order,
        NTILE(3) OVER (ORDER BY total_belanja DESC) AS tile_rank
	FROM total_per_customer
),
final AS (
	SELECT
		nama,
        kota,
        total_belanja,
        jumlah_order,
        CASE tile_rank
			WHEN 1 THEN 'VIP'
            WHEN 2 THEN 'Regular'
            WHEN 3 THEN 'New'
		END AS segmen
	FROM dengan_rangking
)
SELECT nama, kota, total_belanja, jumlah_order, segmen
FROM final
ORDER BY total_belanja DESC;

# 5
WITH metrics_order AS (
	SELECT
		status,
        COUNT(order_id) AS jumlah_order,
        COALESCE(SUM(total_harga), 0) AS total_revenue
	FROM orders
    GROUP BY status
),
metrics_produk AS (
	SELECT
		p.nama_produk,
        SUM(oi.quantity) AS total_qty_terjual,
        ROUND(SUM(oi.quantity * oi.harga_satuan), 0) AS total_revenue
	FROM products AS p
    JOIN order_items AS oi ON p.product_id = oi.product_id
    JOIN orders AS o ON oi.order_id = o.order_id AND o.status = 'selesai'
    GROUP BY p.product_id, p.nama_produk
    ORDER BY total_revenue DESC
    LIMIT 3
),
metrics_customer AS (
	SELECT
		c.nama,
        c.kota,
        COUNT(o.order_id) AS jumlah_order,
        ROUND(SUM(o.total_harga), 2) AS total_belanja
	FROM customers AS c
    JOIN orders AS o ON c.customer_id = o.customer_id
    WHERE o.status = 'selesai'
    GROUP BY c.customer_id, c.nama, c.kota
    ORDER BY total_belanja DESC
    LIMIT 3
),
metrics_kategori AS (
	SELECT
		p.kategori,
        COUNT(DISTINCT o.order_id) AS jumlah_order,
        ROUND(SUM(oi.quantity * oi.harga_satuan), 2) AS total_revenue
	FROM products AS p
    JOIN order_items AS oi ON p.product_id = oi.product_id
    JOIN orders AS o ON oi.order_id = o.order_id AND o.status = 'selesai'
    GROUP BY p.kategori
    ORDER BY total_revenue DESC
)
SELECT * FROM metrics_order ORDER BY total_revenue DESC;
SELECT * FROM metrics_produk;
SELECT * FROM metrics_customer;
SELECT * FROM metrics_kategori;

# Hari 11
# 1
SELECT
	a.nama_produk	AS	produk_a,
    b.nama_produk	AS	produk_b,
    a.kategori,
    a.harga			AS	harga_a,
    b.harga			AS	harga_b,
    a.harga - b.harga	AS selisih_harga
FROM products AS a
JOIN products AS b
	ON a.kategori = b.kategori
    AND a.product_id < b.product_id
ORDER BY a.kategori, selisih_harga;

# 2
SELECT c.nama, o.order_id, o.status
FROM customers AS c
LEFT JOIN orders AS o ON c.customer_id = o.customer_id
UNION
SELECT c.nama, o.order_id, o.status
FROM customers AS c
RIGHT JOIN orders AS o ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;

# 3
SELECT
	p.nama_produk,
    p.harga,
    t.tier_nama
FROM products AS p
JOIN (
	SELECT 'Budget' AS tier_nama, 0 AS min_harga, 200000 AS max_harga
    UNION ALL SELECT 'Mid-range', 200001, 1000000
    UNION ALL SELECT 'Premium', 1000001, 9999999
) t ON p.harga BETWEEN t.min_harga AND t.max_harga
ORDER BY p.harga;

# 4
SELECT
	c.nama,
    c.kota,
    o.order_id,
    o.tanggal_order,
    o.status,
    o.total_harga
FROM customers AS c
INNER JOIN (
	SELECT customer_id, MAX(tanggal_order) AS max_tanggal
    FROM orders
    GROUP BY customer_id
) last_date ON c.customer_id = last_date.customer_id
INNER JOIN orders AS o ON c.customer_id = o.customer_id
					AND last_date.max_tanggal = o.tanggal_order
ORDER BY c.nama;

# 5
WITH revenue_produk AS (
	SELECT
		p.product_id,
        p.nama_produk AS nama,
        p.kategori,
        COALESCE(SUM(oi.quantity * oi.harga_satuan), 0) AS revenue
	FROM products AS p
    LEFT JOIN order_items AS oi ON p.product_id = oi.product_id
	GROUP BY p.product_id, p.nama_produk, p.kategori
)
SELECT
	a.nama AS nama_produk_a,
    b.nama AS nama_produk_b,
    a.kategori,
    a.revenue AS revenue_a,
    b.revenue AS revenue_b,
    ROUND(ABS(a.revenue - b.revenue), 2) AS selisih
FROM revenue_produk AS a
JOIN revenue_produk AS b ON a.kategori = b.kategori
						AND a.product_id < b.product_id
						AND ABS(a.revenue - b.revenue) < 1000000
ORDER BY a.kategori, selisih ASC;

# HARI 12
# 1

SELECT
	nama,
    email,
	LEFT(email, LOCATE('@', email) -1)	AS username,
    SUBSTRING(email, LOCATE('@', email) + 1)	AS domain,
    CHAR_LENGTH(LEFT(email, LOCATE('@', email) - 1))	AS panjang_username
FROM customers
ORDER BY panjang_username ASC;

# 2
SELECT
	CONCAT('PRD-', LPAD(product_id, 3, '0'))	AS kode_produk,
	nama_produk,
    kategori,
    harga,
    CONCAT('Rp ', FORMAT(harga, 0))	AS harga_format,
	CONCAT('Rp ',LPAD(FORMAT(harga, 0), 15, '	'))	AS harga_aligned
FROM products
ORDER BY harga DESC;

# 3
SELECT
	nama,
    TRIM(LOWER(email))	AS email_bersih,
    REPLACE(no_telepon, '-', '')	AS telepon_bersih,
    CONCAT(UPPER(LEFT(nama, 1)),
		LOWER(SUBSTRING(nama, 2)))	AS nama_proper,
	CONCAT(LEFT(nama, 1), '-',
    SUBSTRING(nama, LOCATE(' ', nama) + 1, 1)) AS inisial
FROM customers;

# 4
-- Kelompokkan email
SELECT
	CASE
		WHEN REPLACE(LOWER(email), ' ', '') REGEXP '@gmail' THEN 'Gmail'
        ELSE 'Bukan Gmail'
	END AS kategori_domain,
    COUNT(*) AS jumlah_customer
FROM customers
GROUP BY kategori_domain;

-- Tampilan semua customer dengan nomor telepon terformat
SELECT
	nama,
    email,
    CONCAT(
		LEFT(no_telepon, 4),
        '-',
        SUBSTRING(no_telepon, 5, 4),
        '-',
        SUBSTRING(no_telepon, 9)
        ) AS no_telepon_terformat
FROM customers;

# 5 
SELECT
	CONCAT('ORD-', LPAD(o.order_id, 4, '0')) AS kode_order,
    CONCAT(c.nama, ' (', UPPER(LEFT(c.kota, 3)), ')') AS nama_customer,
    CONCAT(p.nama_produk, ' (', p.kategori, ')') AS nama_produk_kategori,
    CONCAT('Rp ', FORMAT(oi.harga_satuan, 0)) AS harga_rupiah,
    CONCAT('Rp ', FORMAT(oi.subtotal, 0)) AS subtotal_format
FROM orders AS o
JOIN customers AS c ON o.customer_id = c.customer_id
JOIN order_items AS oi ON o.order_id = oi.order_id
JOIN products AS p ON oi.product_id = p.product_id
ORDER BY o.order_id ASC;

# Hari 13
# 1
SELECT
	nama,
    DATE_FORMAT(tanggal_daftar, '%d %M %Y') AS tanggal_daftar,
    DATEDIFF(CURDATE(), tanggal_daftar) AS hari_bergabung,
    TIMESTAMPDIFF(MONTH, tanggal_daftar, CURDATE()) AS bulan_bergabung,
    YEAR(tanggal_daftar) AS tahun_daftar
FROM customers
WHERE tanggal_daftar IS NOT NULL
ORDER BY tanggal_daftar ASC;

# 2
-- Dengan CTE + handle NULL
WITH monthly_orders AS (
	SELECT
		YEAR(tanggal_order)					AS tahun,
		MONTH(tanggal_order)				AS bulan,
		DATE_FORMAT(tanggal_order, '%M %Y')	AS nama_bulan,
		COALESCE(total_harga, 0) AS revenue
FROM orders
WHERE status = 'selesai'
)
SELECT
	tahun,
    bulan,
    nama_bulan,
    COUNT(*) AS jumlah_order,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(revenue), 2) AS rata_rata_order
FROM monthly_orders
GROUP BY tahun, bulan, nama_bulan
ORDER BY tahun, bulan;

# 3
WITH order_days AS (
	SELECT
		DAYOFWEEK(tanggal_order)	AS day_number,
		DAYNAME(tanggal_order) AS nama_hari,
		total_harga
FROM orders
)
SELECT
	nama_hari,
	COUNT(*) AS jumlah_order,
    ROUND(SUM(total_harga), 2) AS total_revenue,
    CASE
		WHEN day_number BETWEEN 2 AND 6 THEN 'Weekday'
        ELSE 'Weekend'
	END AS kategori_hari
FROM order_days
GROUP BY day_number, nama_hari
ORDER BY
	CASE day_number WHEN 1 THEN 8 ELSE day_number END;

# 4
WITH monthly_revenue AS (
	SELECT
		DATE_FORMAT(tanggal_order, '%Y-%m') AS nama_bulan,
        SUM(total_harga) AS revenue
	FROM orders
    WHERE status = 'selesai'
    GROUP BY nama_bulan
),
revenue_with_lag AS (
	SELECT
		nama_bulan,
        revenue AS revenue_bulan_ini,
        LAG(revenue, 1) OVER (ORDER BY nama_bulan) AS revenue_bulan_lalu
	FROM monthly_revenue
)
SELECT
	nama_bulan,
    revenue_bulan_ini,
    COALESCE(revenue_bulan_lalu, 0) AS revenue_bulan_lalu,
    CASE
		WHEN revenue_bulan_lalu IS NULL OR revenue_bulan_lalu = 0 THEN 0
        ELSE ROUND(((revenue_bulan_ini - revenue_bulan_lalu) / revenue_bulan_lalu) * 100, 2)
	END AS pertumbuhan_persen,
    CASE
		WHEN revenue_bulan_lalu IS NULL THEN 'N/A (Data Pertama)'
        WHEN revenue_bulan_ini > revenue_bulan_lalu THEN 'Naik'
        WHEN revenue_bulan_ini < revenue_bulan_lalu THEN 'Turun'
        ELSE 'Sama'
	END AS tren
    FROM revenue_with_lag
    ORDER BY nama_bulan ASC;
    
# 5
SELECT
	c.nama AS nama_customer,
    MIN(o.tanggal_order) AS tanggal_pertama,
    MAX(o.tanggal_order) AS tanggal_terakhir,
    DATEDIFF(MAX(o.tanggal_order), MIN(o.tanggal_order)) AS durasi_aktif_hari,
    COUNT(*) AS total_order,
    SUM(o.total_harga) AS total_belanja,
    TIMESTAMPDIFF(MONTH, MIN(o.tanggal_order), MAX(o.tanggal_order)) AS bulan_aktif,
    ROUND(
		SUM(o.total_harga) / NULLIF(TIMESTAMPDIFF(MONTH, MIN(o.tanggal_order), MAX(o.tanggal_order)), 0), 
        2) AS rata_rata_belanja_per_bulan,
    CASE
		WHEN DATEDIFF(CURDATE(), MAX(o.tanggal_order)) <= 60 THEN 'Aktif'
        ELSE 'Tidak Aktif'
	END AS status_customer
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.nama
ORDER BY total_belanja DESC;

# HARI 14
# 1
WITH order_metrics AS (
	SELECT
		status,
        COUNT(order_id) AS jumlah_order,
        SUM(total_harga) AS total_revenue
	FROM orders
    WHERE tanggal_order >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY status
),
total_stats AS (
	SELECT
		SUM(jumlah_order) AS total_order,
        SUM(CASE WHEN status = 'selesai' THEN jumlah_order ELSE 0 END) AS complete_orders,
        SUM(CASE WHEN status = 'batal' THEN total_revenue ELSE 0 END) AS lost_revenue
	FROM order_metrics
)
SELECT
	om.status,
    om.jumlah_order,
    ROUND(om.jumlah_order * 100.0 / ts.total_order, 2) AS presentase,
    CASE
		WHEN om.status = 'batal' THEN ROUND(om.total_revenue, 2)
        ELSE 0
	END AS total_revenue_lost,
    ROUND(ts.complete_orders * 100.0 / ts.total_order, 2) AS conversion_rate_global,
    ROUND(ts.lost_revenue, 2) AS total_lost_revenue_period
FROM order_metrics AS om
CROSS JOIN total_stats AS ts
ORDER BY
	CASE om.status
		WHEN 'selesai' THEN 1
		WHEN 'diproses' THEN 2
		WHEN 'pending' THEN 3
		WHEN 'batal' THEN 4
	END;
    
# 2
-- Menghitung metrik RFM per customer (hanya order selesai)
WITH rfm_base AS (
	SELECT
		c.customer_id,
		c.nama,
		DATEDIFF(CURDATE(), MAX(o.tanggal_order)) AS recency,
		COUNT(o.order_id) AS frequency,
		ROUND(SUM(o.total_harga), 2) AS monetary
	FROM customers AS c
	JOIN orders AS o ON c.customer_id = o.customer_id
	WHERE o.status = 'selesai'
	GROUP BY c.customer_id, c.nama
)
SELECT
	customer_id,
    nama,
    recency,
    frequency,
    monetary,
    CASE
		WHEN recency <= 30 AND frequency >= 2 THEN 'Champion'
        WHEN frequency >= 2 THEN 'Loyal'
        WHEN recency > 60 THEN 'At Risk'
        ELSE 'Regular'
	END AS segmen_rfm
FROM rfm_base
ORDER BY
	CASE segmen_rfm
		WHEN 'Champion' THEN 1
        WHEN 'Loyal' THEN 2
        WHEN 'At Risk' THEN 3
        ELSE 4
	END,
monetary DESC;

# 3
-- Agregasi dasar per produk (hanya orders selesai)
WITH product_metrics AS (
	SELECT
		p.product_id,
        p.nama_produk,
        COALESCE(SUM(oi.quantity), 0) AS total_qty_terjual,
        COALESCE(SUM(oi.quantity * oi.harga_satuan), 0) AS total_revenue
	FROM products AS p
	LEFT JOIN order_items AS oi ON p.product_id = oi.product_id
    LEFT JOIN orders AS o ON oi.order_id = o.order_id AND o.status = 'selesai'
    GROUP BY p.product_id, p.nama_produk
)
-- Tambahkan window Function & Labeling
SELECT
	nama_produk,
    total_qty_terjual,
	ROUND(total_revenue, 2) AS total_revenue,
    ROUND(total_revenue * 100.0 / NULLIF(SUM(total_revenue) OVER (), 0), 2) AS kontribusi_persen,
    RANK() OVER (ORDER BY total_revenue DESC) AS rangking_revenue,
    CASE
		WHEN RANK() OVER (ORDER BY total_revenue DESC) <= 3 THEN 'Star'
        WHEN total_revenue > AVG(total_revenue) OVER () THEN 'Normal'
        ELSE 'Underperform'
	END AS label_performa
FROM product_metrics
ORDER BY total_revenue DESC;

# 4
-- Agregasi dasar per bulan (hanya order selesai)
WITH monthly_base AS (
	SELECT
		YEAR(tanggal_order) AS tahun,
        MONTH(tanggal_order) AS bulan,
        DATE_FORMAT(tanggal_order, '%Y-%m') AS periode,
        COUNT(order_id) AS jumlah_order,
        ROUND(SUM(total_harga), 2) AS total_revenue,
        ROUND(AVG(total_harga), 2) AS aov -- Average order value
	FROM orders
    WHERE status = 'selesai'
    GROUP BY
		YEAR(tanggal_order),
        MONTH(tanggal_order),
        DATE_FORMAT(tanggal_order, '%Y-%m')
),
monthly_with_lag AS (
-- Tambahkan revenue bulan sebelumnya menggunakan LAG()
	SELECT
		*,
        LAG(total_revenue, 1) OVER (ORDER BY tahun, bulan) AS revenue_bulan_sebelumnya,
        SUM(total_revenue) OVER (ORDER BY tahun, bulan ROWS UNBOUNDED PRECEDING) AS running_total
	FROM monthly_base
)
-- Hitung growth metrics & label tren
SELECT
	CONCAT(
		ELT(bulan, 'Jan','Feb','Mar','Apr','Mei','Jun','Jul','Aug','Sep','Okt','Nov','Des'),
        ' ', tahun
	) AS nama_bulan,
    jumlah_order,
    total_revenue,
    aov,
    revenue_bulan_sebelumnya,
    ROUND(total_revenue - COALESCE(revenue_bulan_sebelumnya, 0), 2) AS pertumbuhan_absolut,
    CASE
		WHEN revenue_bulan_sebelumnya IS NULL THEN NULL
        WHEN revenue_bulan_sebelumnya = 0 THEN NULL
        ELSE ROUND((total_revenue - revenue_bulan_sebelumnya) / revenue_bulan_sebelumnya * 100, 2)
	END AS pertumbuhan_persen,
    ROUND(running_total, 2) AS revenue_kumulatif,
    CASE
		WHEN revenue_bulan_sebelumnya IS NULL THEN 'Data Awal'
        WHEN total_revenue > revenue_bulan_sebelumnya * 1.1 THEN 'Naik Signifikan'
        WHEN total_revenue > revenue_bulan_sebelumnya THEN 'Naik'
        WHEN total_revenue < revenue_bulan_sebelumnya * 0.9 THEN 'Turun Signifikan'
        WHEN total_revenue < revenue_bulan_sebelumnya THEN 'Turun'
        ELSE 'Stabil'
	END AS label_tren
FROM monthly_with_lag
ORDER BY tahun, bulan;

# 5
WITH active_cust AS (
-- Total customer aktif
	SELECT CAST(COUNT(*) AS CHAR) AS metric_value
    FROM customers
    WHERE is_active = 1
),
rev_comparison AS (
-- Revenue Bulan ini vs Bulan lalu
	SELECT CONCAT(
		FORMAT(SUM(CASE WHEN DATE_FORMAT(tanggal_order, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m') THEN total_harga END), 0),
        ' | ',
        FORMAT(SUM(CASE WHEN DATE_FORMAT(tanggal_order, '%Y-%m') = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m') THEN total_harga END), 0)
        ) AS metric_value
        FROM orders
        WHERE status = 'selesai'
),
top_product AS (
-- produk terlaris Bulan ini (dengan window function)
	SELECT
		CONCAT(p.nama_produk, ' (', SUM(oi.quantity), ' unit)') AS metric_value,
        RANK() OVER (ORDER BY SUM(oi.quantity) DESC) AS rnk
	FROM products AS p
    JOIN order_items AS oi ON p.product_id = oi.product_id
    JOIN orders AS o ON oi.order_id = o.order_id
    WHERE o.status = 'selesai'
		AND DATE_FORMAT(o.tanggal_order, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m')
	GROUP BY p.product_id, p.nama_produk
),
top_customer AS (
-- Customer terbaik bulan ini (dengan window function)
	SELECT
		CONCAT(c.nama, ' (Rp ', FORMAT(SUM(o.total_harga), 0), ')') AS metric_value,
        RANK() OVER (ORDER BY SUM(o.total_harga) DESC) AS rnk
	FROM customers AS c
    JOIN orders AS o ON c.customer_id = o.customer_id
    WHERE o.status = 'selesai'
		AND DATE_FORMAT(o.tanggal_order, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m')
	GROUP BY c.customer_id, c.nama
),
category_growth AS (
-- Kategori dengan growth tertinggi
	SELECT
		CONCAT(kategori, ' (+', FORMAT(growth_pct, 1), '%)') AS metric_value
	FROM (
		SELECT p.kategori,
			ROUND(
				(SUM(CASE WHEN DATE_FORMAT(o.tanggal_order, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m') THEN o.total_harga ELSE 0 END) -
				 SUM(CASE WHEN DATE_FORMAT(o.tanggal_order, '%Y-%m') = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m') THEN o.total_harga ELSE 0 END))
                 / NULLIF(SUM(CASE WHEN DATE_FORMAT(o.tanggal_order, '%Y-%m') = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m') THEN o.total_harga ELSE 0 END), 0) * 100, 2
			) AS growth_pct
		FROM products AS p
        JOIN order_items AS oi ON p.product_id = oi.product_id
        JOIN orders AS o ON oi.order_id = o.order_id
        WHERE o.status = 'selesai'
			AND (DATE_FORMAT(o.tanggal_order, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m')
			  OR DATE_FORMAT(o.tanggal_order, '%Y-%m') = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m'))
        GROUP BY p.kategori
        HAVING SUM(CASE WHEN DATE_FORMAT(o.tanggal_order, '%Y-%m') = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m') THEN o.total_harga ELSE 0 END) > 0
        ORDER BY growth_pct DESC
        LIMIT 1
	)sub
)
-- Gabungkan semua metrik menjadi 2 kolom
SELECT 'Total Customer Aktif' AS metric_name, metric_value FROM active_cust
UNION ALL
SELECT 'Revenue Bulan Ini | Bulan Lalu' AS metric_name, metric_value FROM rev_comparison
UNION ALL
SELECT 'Produk Terlaris Bulan Ini' AS metric_name, metric_value FROM top_product WHERE rnk = 1
UNION ALL
SELECT 'Customer Terbaik Bulan Ini' AS metric_name, metric_value FROM top_customer WHERE rnk = 1
UNION ALL
SELECT 'Kategori dengan Growth Tertinggi' AS metric_name, metric_value FROM category_growth;


# HARI 15
# 1
-- Ubah delimiter sementara agar MYSQL tidak error saat membaca END IF;
DELIMITER //

CREATE PROCEDURE sp_laporan_order_status(IN p_status VARCHAR(20))
BEGIN
	-- logika kondisi sesuai petunjuk
    IF p_status = 'SEMUA' THEN
		-- tampilkan SEMUA order tanpa filter status
        SELECT
			o.order_id,
            o.tanggal_order,
            o.status,
            o.total_harga,
            c.nama AS nama_customer
		FROM orders AS o
        JOIN customers AS c ON o.customer_id = c.customer_id
        ORDER BY o.tanggal_order DESC;
	ELSE
		-- tampilkan HANYA order dengan status yang sesuai parameter
        SELECT
			o.order_id,
            o.tanggal_order,
            o.status,
            o.total_harga,
            c.nama AS nama_customer
		FROM orders AS o
        JOIN customers AS c ON o.customer_id = c.customer_id
        WHERE o.status = p_status
        ORDER BY o.tanggal_order DESC;
	END IF;
END //

-- 2. kembali delimiter ke default
DELIMITER ;

-- test 1: Hanya order yang statusnya 'selesai'
CALL sp_laporan_order_status('selesai');

-- test 2: semua order tanpa filter status
CALL sp_laporan_order_status('SEMUA');

-- Optimasi performa
CREATE INDEX idx_orders_status_date ON orders(status, tanggal_order, customer_id);
CREATE INDEX idx_customers_id ON customers(customer_id);

# 2
DELIMITER //

CREATE PROCEDURE sp_hitung_revenue (
	IN p_status VARCHAR(20),
    OUT p_total DECIMAL(15,2)
)
BEGIN
	SELECT COALESCE(SUM(total_harga), 0) INTO p_total
    FROM orders
    WHERE status = p_status;
END //

DELIMITER ;

-- Menguji test
-- Panggil procedure dengan status 'selesai'
CALL sp_hitung_revenue('selesai', @total2);

-- Tampilkan hasil yang tersimpan di variabel session
SELECT @total2 AS total_revenue_selesai;

-- test lain: status yang tidak ada datanya (harus return 0, bukan NULL)
CALL sp_hitung_revenue('dikirim', @total2);
SELECT @total2 AS total_revenue_dikirim;

# 3
-- 1. Ubah delimiter sementara agar MySQL tidak konflik dengan titik koma di dalam procedure
DELIMITER //

CREATE PROCEDURE sp_laporan_produk_kategori(
	IN p_kategori VARCHAR(50),
    IN p_min_harga DECIMAL(12,2)
)
	-- validasi: tolak jika hanya minimum negatif
BEGIN
    IF p_min_harga < 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Parameter harga minimum tidak boleh bernilai negatif';
	END IF;
    
    -- query produk sesuai filter kategori & harga
    SELECT
		product_id,
        nama_produk,
        kategori,
        harga,
        stok
	FROM products
    WHERE kategori = p_kategori
		AND harga >= p_min_harga
	ORDER BY harga DESC;
END //

-- 2. kembali delimiter ke default
DELIMITER ;

# Test Cases & Expert Output
-- test 1. parameter valid (akan return daftar produk)
CALL sp_laporan_produk_kategori('Fashion', 100000);

-- test 2. harga minimum 0 (produk gratis/murah tetap muncul)
CALL sp_laporan_produk_kategori('Aksesoris', 0);

-- test 3. Harga negatif (akan trigger error 45000)
CALL sp_laporan_produk_kategori('Elektronik', 50000);
-- Output Error: Error Code: 1644. Parameter harga minumum tidak boleh bernilai negatif!

-- test 4: kategori tidak ada (akan return empty set, bulan error)
CALL sp_laporan_produk_kategori('KategoriFiktif', 10000);

# 4
DELIMITER //

CREATE PROCEDURE sp_update_stok_produk(
	IN p_product_id INT,
    IN p_qty_terjual INT,
    OUT p_stok_tersisa INT
)
BEGIN
	DECLARE stok_sekarang INT;
    
    -- Mulai transaksi eksplisit
    START TRANSACTION;
    
    -- Ambil stok saat ini & KUNCI baris (FOR UPDATE) untuk hindari race condition
    SELECT stok INTO stok_sekarang
    FROM products
    WHERE product_id = p_product_id
    FOR UPDATE;
    
    -- Validasi: produk tidak ditemukan
    IF stok_sekarang IS NULL THEN
		ROLLBACK;
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Produk tidak ditemukan!';
	END IF;
    
    -- Validasi: stok tidak mencukupi
    IF stok_sekarang < p_qty_terjual THEN
		ROLLBACK;
        SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = CONCAT('Stok tidak mencukupi! Tersedia: ', stok_sekarang, ', Dibutuhkan: ', p_qty_terjual);
		END IF;
	
    -- kurangi stok
    UPDATE products
    SET stok = stok - p_qty_terjual
    WHERE product_id = p_product_id;
    
    -- Hitung & kembalikan sisa stok ke parameter OUT
    SET p_stok_tersisa = stok_sekarang - p_qty_terjual;
    
    -- Simpan perubahan permanen
    COMMIT;
END;

DELIMITER //

-- Test 1: Sukses (stok cukup)
CALL sp_update_stok_produk(101, 5, @sisa);
SELECT @sisa AS stok_tersisa;

-- Test 2: Stok tidak cukup (trigger rollback + error)
CALL sp_update_stok_produk(101, 9999, @sisa);
-- Error 1644: Stok tidak mencukupi! Tersedia: 10, Dibutuhkan: 9999

-- Test 3: Produk tidak ada
CALL sp_update_stok_produk(999, 2, @sisa);
-- Error 1644: Produk tidak ditemukan!

-- Cek konsistensi data setelah rollback
SELECT product_id, nama_produk, stok FROM products WHERE product_id = 101;
-- Stok tetap sama seperti sebelum Test 2 (karena ROLLBACK berjalan)

# 5
DELIMITER //

CREATE PROCEDURE sp_dashboard_summary()
BEGIN
	SELECT
		'Customer' AS kategori,
        'Total Customer Aktif' AS metrik,
        CAST(COUNT(*) AS CHAR) AS nilai
	FROM customers
    WHERE is_active = 1
    
    UNION ALL
    SELECT 'Produk', 'Total Produk Tersedia', CAST(COUNT(*) AS CHAR)
    FROM products
    WHERE stok > 0
    
    UNION ALL
    SELECT 'Order', 'Total Order Masuk', CAST(COUNT(*) AS CHAR)
    FROM orders
    
    UNION ALL
    SELECT 'Revenue', 'Revenue Bulan Ini', FORMAT(COALESCE(SUM(total_harga), 0), 2)
    FROM orders
    WHERE status = 'selesai'
		AND DATE_FORMAT(tanggal_order, '%Y-%m') = DATE_FORMAT(CURDATE(), '%Y-%m')
        
	UNION ALL
    (SELECT 'Produk', 'Produk Terlaris', CONCAT(p.nama_produk, ' (', SUM(oi.quantity), ' unit)')
	FROM products AS p
    JOIN order_items AS oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.nama_produk
    ORDER BY SUM(oi.quantity) DESC LIMIT 1)
    
    UNION ALL
    (SELECT 'Customer', 'Customer Terbaik', CONCAT(c.nama, ' (Rp ', FORMAT(SUM(o.total_harga), 0), ')')
    FROM customers AS c
    JOIN orders AS o ON c.customer_id = o.customer_id
    WHERE o.status = 'selesai'
    GROUP BY c.customer_id, c.nama
    ORDER BY SUM(o.total_harga) DESC LIMIT 1)
    
    UNION ALL
    (SELECT 'Kategori', 'Kategori Terlaris', CONCAT(p.kategori, ' (Rp ', FORMAT(SUM(oi.quantity * oi.harga), 0), ')')
    FROM products AS p
    JOIN order_items AS oi ON p.product_id = oi.product_id
    JOIN orders AS o ON oi.order_id = o.order_id
    WHERE o.status = 'selesai'
    GROUP BY p.kategori
    ORDER BY SUM(oi.quantity * oi.harga_satuan) DESC LIMIT 1)
    
    UNION ALL
    SELECT 'Performa', 'Conversion Rate',
			CONCAT(ROUND(
				(SELECT COUNT(*) FROM orders WHERE status = 'selesai') * 100.0 /
                NULLIF((SELECT COUNT(*) FROM orders), 0), 2), '%');
END //

DELIMITER ;

CALL sp_dashboard_summary();

# ------------------------------------------------------------------------------------------------------------------

# HARI 16

# 1

# View Order lengkap (4 Tabel Join)
CREATE OR REPLACE VIEW vw_order_lengkap AS
SELECT
	o.order_id,
    o.tanggal_order,
    o.status,
    o.total_harga AS total_order,
    c.nama AS nama_customer,
    c.kota,
    p.nama_produk,
    p.kategori,
    oi.quantity,
	oi.harga_satuan,
    ROUND(oi.quantity * oi.harga_satuan, 2) AS subtotal_item 
FROM orders AS o
JOIN customers AS c ON o.customer_id = c.customer_id
JOIN order_items AS oi ON o.order_id = oi.order_id
JOIN products as p ON oi.product_id = p.product_id;

-- Test 1: Lihat 5 baris pertama order lengkap
SELECT * FROM vw_order_lengkap LIMIT 5;

# View Summary Customer
CREATE OR REPLACE VIEW vw_summary_customer AS
SELECT
	c.nama,
    c.kota,
    COUNT(o.order_id) AS jumlah_order,
    COALESCE(ROUND(SUM(o.total_harga), 2), 0) AS total_belanja
FROM customers AS c
LEFT JOIN orders AS o ON c.customer_id = o.customer_id AND o.status = 'selesai'
GROUP BY c.customer_id, c.nama, c.kota;

-- Test 2: Lihat 5 customer dengan belanja tertinggi
SELECT * FROM vw_summary_customer ORDER BY total_belanja DESC LIMIT 5;

# View Performa Produk
CREATE OR REPLACE VIEW vw_produk_performa AS
SELECT
	p.nama_produk,
    p.kategori,
    COALESCE(SUM(oi.quantity), 0) AS total_quantity_terjual,
    COALESCE(ROUND(SUM(oi.quantity * oi.harga_satuan), 2), 0) AS total_revenue,
    p.stok AS stok_tersisa,
    CASE
		WHEN p.stok = 0 THEN 'Habis'
        WHEN p.stok < 20 THEN 'Menipis'
        ELSE 'Aman'
	END AS status_stok
FROM products AS p
LEFT JOIN order_items AS oi ON p.product_id = oi.product_id
LEFT JOIN orders AS o ON oi.order_id = o.order_id AND o.status = 'selesai'
GROUP BY p.product_id, p.nama_produk, p.kategori, p.stok;

-- Test 3: Lihat 5 produk dengan revenue tertinggi
SELECT * FROM vw_produk_performa ORDER BY total_revenue DESC LIMIT 5;
