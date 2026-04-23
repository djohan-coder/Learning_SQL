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


# 2

-- Buat tabel Log Aktivitas
CREATE TABLE IF NOT EXISTS log_aktivitas (
	log_id INT AUTO_INCREMENT PRIMARY KEY,
    tabel_name VARCHAR(50) NOT NULL,
    aksi VARCHAR(10) NOT NULL,
    data_lama TEXT,
    data_baru TEXT,
    waktu DATETIME DEFAULT NOW(),
    user_db VARCHAR(100)
);

-- 1. Cek log sebelum insert (harus kosong atau berisi log lama)
SELECT * FROM log_aktivitas ORDER BY waktu DESC LIMIT 5;

# Buat Trigger AFTER INSERT pada tabel orders
DELIMITER //

CREATE TRIGGER trg_audit_insert_orders
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
	INSERT INTO log_aktivitas (tabel_name, aksi, data_lama, data_baru, waktu, user_db)
    VALUES	(
		'orders',
        'INSERT',
        NULL,
        CONCAT('order_id:', NEW.order_id,
				' | customer_id:', NEW.customer_id,
                ' | status:', NEW.status,
                ' | total_harga:', NEW.total_harga),
		NOW(),
        USER()
	);
END //

DELIMITER ;

-- 2. Insert order baru (memicu trigger otomatis)
INSERT INTO orders (customer_id, tanggal_order, status, total_harga)
VALUES (2, NOW(), 'pending', 1250000);

-- 3. Cek log setelah insert (harus muncul 1 baris baru)
SELECT * FROM log_aktivitas ORDER BY waktu DESC LIMIT 5;


# 3

-- Buat Trigger BEFORE UPDATE
DELIMITER //

CREATE TRIGGER trg_validate_lag_products
BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
	-- Deklarasi variabel harus di paling awal blok BEGIN ... END
    DECLARE err_msg VARCHAR(255);
    
	-- validasi 1: cegah stok negatif
    IF NEW.stok < 0 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Gagal Update: Stok produk tidak boleh bernilai negatif!';
	END IF;
    
	-- validasi 2: cegah penurunan harga > 50%
    IF NEW.harga < (OLD.harga * 0.5) THEN
		-- simpan pesan dinamis ke variabel
        SET err_msg = CONCAT('Gagal Update: Penurunan harga maksimal 50% dari harga lama (',
							OLD.harga, '). Minimal harga baru: ', ROUND(OLD.harga * 0.5, 2));
                            
		-- baru panggil variabel di SIGNAL
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = err_msg;
	END IF;
    
    -- logging: catat hanya jika harga benar-benar berubah
    -- Gunakan <=> untuk aman jika kolom harga boleh NULL
    IF NOT(NEW.harga <=> OLD.harga) THEN
		INSERT INTO log_aktivitas (tabel_name, aksi, data_lama, data_baru, waktu, user_db)
        VALUES (
			'products',
            'UPDATE',
            CONCAT('product_id:', OLD.product_id, ' | harga_lama:', OLD.harga),
            CONCAT('product_id:', NEW.product_id, ' | harga_baru:', NEW.harga),
            NOW(),
            USER()
		);
	END IF;
END //

DELIMITER ;

-- Test 1: Update harga valid (turun 10%)
UPDATE products SET harga = 90000 WHERE product_id = 1;
-- Output: Query OK, 1 row affected. Cek log_aktivitas → 1 baris baru tercatat.

-- ❌ Test 2: Update harga invalid (turun 60%)
UPDATE products SET harga = 30000 WHERE product_id = 1;
-- Output: Error 1644. "Gagal Update: Penurunan harga maksimal 50% dari harga lama (100000). Minimal harga baru: 50000.00"

-- ❌ Test 3: Update stok negatif
UPDATE products SET stok = -5 WHERE product_id = 1;
-- Output: Error 1644. "Gagal Update: Stok produk tidak boleh bernilai negatif!"
--  Cek Log Aktivitas


SELECT * FROM log_aktivitas 
WHERE tabel_name = 'products' 
ORDER BY waktu DESC LIMIT 5;


# 4

-- Buat trigger BEFORE DELETE
DELIMITER //

CREATE TRIGGER trg_soft_delete_customer
BEFORE DELETE ON customers
FOR EACH ROW
BEGIN
	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Direct DELETE tidak diizinkan. Gunakan sp_soft_delete_customer()';
END//

DELIMITER ;

--  Test 1: Coba DELETE customer (akan terintercept trigger)
DELETE FROM customers WHERE customer_id = 2;
-- Output: Error 1644. "DELETE dibatalkan. Customer telah di-soft delete..."

--  Cek apakah status berubah (tergantung engine DB, lihat catatan di bawah)
SELECT customer_id, nama, is_active FROM customers WHERE customer_id = 101;

DELIMITER //
CREATE PROCEDURE sp_soft_delete_customer(IN p_customer_id INT)
BEGIN
    UPDATE customers SET is_active = 0 WHERE customer_id = p_customer_id;
    
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer tidak ditemukan.';
    END IF;
END //
DELIMITER ;

-- Panggil dari aplikasi:
CALL sp_soft_delete_customer(101);


# 5

-- 1️ TABEL LOG: Menyimpan riwayat alert stok
DROP TRIGGER IF EXISTS trg_nama;
DROP VIEW IF EXISTS vw_nama;
CREATE TABLE IF NOT EXISTS stok_alert (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    stok_sebelum INT,
    stok_sesudah INT,
    waktu_alert DATETIME DEFAULT NOW(),
    status_alert VARCHAR(20) DEFAULT 'BELUM DITINDAK',
    INDEX idx_prod_status (product_id, status_alert),
    INDEX idx_waktu (waktu_alert)
);

-- 2️ VIEW: Real-time warning stok < 20
CREATE OR REPLACE VIEW vw_stok_warning AS
SELECT 
    product_id,
    nama_produk,
    kategori,
    stok,
    CASE 
        WHEN stok = 0 THEN 'Habis'
        ELSE 'Menipis'
    END AS status_stok
FROM products
WHERE stok >= 0 AND stok < 20;

-- 3️ TRIGGER: Otomatis catat saat stok MENEMBUS batas 20
DELIMITER //
CREATE TRIGGER trg_monitor_stok_rendah
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    -- Hanya trigger saat stok BERUBAH dari >=20 menjadi <20
    IF NEW.stok < 20 AND OLD.stok >= 20 THEN
        INSERT INTO stok_alert (product_id, stok_sebelum, stok_sesudah, status_alert)
        VALUES (NEW.product_id, OLD.stok, NEW.stok, 'BELUM DITINDAK');
    END IF;
END //
DELIMITER ;

-- Asumsi awal: product_id=50, nama='Kaos Polos', stok=30
UPDATE products SET stok = 25 WHERE product_id = 50; 
-- Tidak ada alert (masih >=20)

UPDATE products SET stok = 15 WHERE product_id = 50; 
-- Trigger FIRES! Alert tercatat di stok_alert (30 → 15)

UPDATE products SET stok = 5 WHERE product_id = 50; 
-- Tidak ada alert baru (threshold crossing logic mencegah spam)

-- Cek View (real-time)
SELECT * FROM vw_stok_warning WHERE product_id = 50;

-- Cek Log Alert
SELECT * FROM stok_alert WHERE product_id = 50 ORDER BY waktu_alert DESC;

SELECT 
    v.product_id,
    v.nama_produk,
    v.kategori,
    v.stok AS stok_saat_ini,
    v.status_stok,
    a.stok_sebelum,
    a.stok_sesudah,
    a.waktu_alert,
    a.status_alert,
    -- Metrik tambahan: berapa hari sejak alert pertama
    DATEDIFF(CURDATE(), a.waktu_alert) AS hari_sejak_alert
FROM vw_stok_warning v
LEFT JOIN stok_alert a ON v.product_id = a.product_id
WHERE a.alert_id IS NULL OR a.alert_id = (
    -- Ambil hanya alert TERBARU per produk agar dashboard tidak duplikat
    SELECT MAX(alert_id) FROM stok_alert sa WHERE sa.product_id = v.product_id
)
ORDER BY v.stok ASC, a.waktu_alert DESC;

-- Setelah buat trigger, verifikasi dengan:
SHOW TRIGGERS FROM tokokita;

-- Setelah buat view:
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- Melihat definisi view:
SHOW CREATE VIEW vw_order_lengkap;

#---------------------------------------------------------------------------------

# HARI 17

-- ============================================================
-- MODUL 1: INFRASTRUKTUR VIEW
-- ============================================================

-- 1. view_transaksi_lengkap
DROP VIEW IF EXISTS vw_transaksi_lengkap;
CREATE OR REPLACE VIEW vw_transaksi_lengkap AS
SELECT
	CONCAT('ORD-', LPAD(o.order_id, 4, '0'))					AS kode_order,
    CONCAT(c.nama, ' (', c.kota, ')')							AS nama_customer_kota,
    CONCAT(p.nama_produk, ' [', p.kategori, ']')				AS nama_produk_kategori,
    CONCAT('Rp ', FORMAT(oi.harga_satuan, 0))					AS harga_rupiah,
    oi.quantity,
    ROUND(oi.quantity * oi.harga_satuan, 2)						AS subtotal_item,
    o.tanggal_order,
    o.status
FROM orders AS o
JOIN customers AS c		ON o.customer_id = c.customer_id
JOIN order_items AS oi	ON o.order_id	 = oi.order_id
JOIN products AS p		ON oi.product_id = p.product_id;

-- Test VIEW 1
SELECT kode_order, nama_customer_kota, nama_produk_kategori, harga_rupiah, subtotal_item
FROM vw_transaksi_lengkap
LIMIT 5;

-- 2. vw_kinerja_customer (RFM Segmentation)
DROP VIEW IF EXISTS vw_kinerja_customer;
CREATE OR REPLACE VIEW vw_kinerja_customer AS
SELECT
	c.customer_id,
    c.nama,
    c.kota,
    COALESCE(DATEDIFF(CURDATE(), MAX(o.tanggal_order)), 999)				AS recency,
    COUNT(o.order_id)														AS frequency,
    COALESCE(ROUND(SUM(o.total_harga), 2), 0)								AS monetary,
    CASE
		WHEN COALESCE(DATEDIFF(CURDATE(), MAX(o.tanggal_order)), 999) <= 30
			AND COUNT(o.order_id) >= 2										THEN 'Champion'
        WHEN COUNT(o.order_id) >= 2											THEN 'Loyal'
        WHEN COALESCE(DATEDIFF(CURDATE(), MAX(o.tanggal_order)), 999) > 60
																			THEN 'At Risk'
        ELSE																	 'Regular'
	END AS segmen_rfm
FROM customers		AS c
LEFT JOIN orders	AS o
		ON c.customer_id = o.customer_id
        AND o.status = 'selesai'
GROUP BY c.customer_id, c.nama, c.kota;

-- Test VIEW 2
SELECT nama, kota, recency, frequency, monetary, segmen_rfm
FROM vw_kinerja_customer
ORDER BY monetary DESC
LIMIT 5;


-- VIEW 3: Kinerja Produk (Revenue + Ranking per Kategori)
DROP VIEW IF EXISTS vw_kinerja_produk;
CREATE VIEW vw_kinerja_produk AS
SELECT
	product_id,
    nama_produk,
    kategori,
    total_qty_terjual,
    total_revenue,
    RANK() OVER (PARTITION BY kategori ORDER BY total_revenue DESC) AS ranking_per_kategori
FROM (
	SELECT
		p.product_id,
		p.nama_produk,
		p.kategori,
		COALESCE(SUM(oi.quantity), 0)								AS total_qty_terjual,
		COALESCE(ROUND(SUM(oi.quantity * oi.harga_satuan), 2), 0)	AS total_revenue
	FROM products AS p
	LEFT JOIN order_items	AS oi	ON p.product_id = oi.product_id
	LEFT JOIN orders		AS o	ON oi.order_id = o.order_id
									AND o.status = 'selesai'
	GROUP BY p.product_id, p.nama_produk, p.kategori
) AS product_agg;

-- Test VIEW 3
SELECT nama_produk, kategori, total_revenue, ranking_per_kategori
FROM vw_kinerja_produk
ORDER BY kategori, ranking_per_kategori;

-- VIEW 4: Tren Bulanan (LAG + Running Total + Growth)
DROP VIEW vw_tren_bulanan;
CREATE VIEW vw_tren_bulanan AS
SELECT
	CONCAT(tahun, '-', LPAD(bulan, 2, '0'))		AS periode,
    jumlah_order,
    total_revenue,
    ROUND(aov, 2)								AS average_order_value,
    revenue_bulan_lalu,
    CASE
		WHEN revenue_bulan_lalu IS NULL
		OR revenue_bulan_lalu = 0				THEN NULL
        ELSE ROUND(
			(total_revenue - revenue_bulan_lalu)
            / revenue_bulan_lalu * 100, 2)
	END											AS pertumbuhan_persen,
    ROUND(running_total, 2)						AS running_total
FROM (
	SELECT
		YEAR(tanggal_order)										AS tahun,
        MONTH(tanggal_order)									AS bulan,
        COUNT(order_id)											AS jumlah_order,
        COALESCE(SUM(total_harga), 0)							AS total_revenue,
        COALESCE(AVG(total_harga), 0)							AS aov,
        LAG(SUM(total_harga)) OVER (
			ORDER BY YEAR(tanggal_order), MONTH(tanggal_order)
		)														AS revenue_bulan_lalu,
        SUM(SUM(total_harga)) OVER (
			ORDER BY YEAR(tanggal_order), MONTH(tanggal_order)
            ROWS UNBOUNDED PRECEDING)							AS running_total
	FROM orders
    WHERE status = 'selesai'
    GROUP BY YEAR(tanggal_order), MONTH(tanggal_order)
) AS monthly_agg;

-- Test VIEW 4
SELECT periode, total_revenue, pertumbuhan_persen, running_total
FROM vw_tren_bulanan
ORDER BY periode;

-- -----------------------------------------------------------------
-- Index pendukung performa VIEW
CREATE INDEX idx_orders_cust_status
    ON orders(customer_id, status, tanggal_order, total_harga);
CREATE INDEX idx_oi_order_prod
    ON order_items(order_id, product_id, quantity, harga_satuan);
CREATE INDEX idx_products_kategori
    ON products(product_id, kategori, harga);


-- ============================================================
-- MODUL 2: SISTEM AUDIT & LOGGING
-- ============================================================

-- 1. TABEL AUDIT LOG
DROP TABLE IF EXISTS audit_log;
CREATE TABLE IF NOT EXISTS audit_log (
    log_id       BIGINT       	AUTO_INCREMENT PRIMARY KEY,
    tabel_name   VARCHAR(50)  	NOT NULL,
    operasi      VARCHAR(20)  	NOT NULL,
    record_id    INT          	NOT NULL,
    data_sebelum JSON,
    data_sesudah JSON,
    waktu        DATETIME    	DEFAULT NOW(),
    user_db      VARCHAR(100)	NULL,
    ip_info      VARCHAR(45)	NULL
);

DROP TRIGGER IF EXISTS trg_audit_insert_orders;
DELIMITER //
CREATE TRIGGER trg_audit_insert_orders
BEFORE INSERT ON audit_log
FOR EACH ROW
BEGIN
	IF NEW.user_db IS NULL THEN
        SET NEW.user_db = SUBSTRING_INDEX(USER(), '@', 1);
    END IF;
    IF NEW.ip_info IS NULL THEN
        SET NEW.ip_info = SUBSTRING_INDEX(USER(), '@', -1);
    END IF;
END //
DELIMITER ;

-- Trigger 2: AFTER UPDATE ON orders (hanya log jika status berubah)
DROP TRIGGER IF EXISTS trg_audit_update_orders;
DELIMITER //
CREATE TRIGGER trg_audit_update_orders
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
	-- Gunakan <=> untuk safe NULL comparison
    IF NOT (OLD.status <=> NEW.status) THEN
		INSERT INTO audit_log (table_name, operasi, record_id, data_sebelum, data_sesudah, ip_info)
		VALUES (
			'orders',
			'UPDATE STATUS',
			NEW.order_id,
			JSON_OBJECT('status_lama', OLD.status),
			JSON_OBJECT('status_baru', NEW.status, 'waktu_update', NOW()),
			SUBSTRING_INDEX(USER(), '@', -1)
		);
	END IF;
END //
DELIMITER ;

-- Trigger 3: AFTER UPDATE ON products (hanya log jika harga/stok berubah)
DROP TRIGGER IF EXISTS trg_audit_update_products;
DELIMITER //
CREATE TRIGGER trg_audit_update_products
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    IF NOT (OLD.harga <=> NEW.harga) OR NOT (OLD.stok <=> NEW.stok) THEN
        INSERT INTO audit_log (table_name, operasi, record_id, data_sebelum, data_sesudah, ip_info)
        VALUES (
            'products',
            'UPDATE_PRICE_STOCK',
            NEW.product_id,
            JSON_OBJECT('harga_lama', OLD.harga, 'stok_lama', OLD.stok),
            JSON_OBJECT('harga_baru', NEW.harga, 'stok_baru', NEW.stok, 'waktu_update', NOW()),
            SUBSTRING_INDEX(USER(), '@', -1)
        );
    END IF;
END //
DELIMITER ;

-- Query verifikasi audit log (10 terbaru)
SELECT
    tabel_name,
    operasi,
    record_id,
    COALESCE(CAST(data_sebelum AS CHAR), 'NULL')    AS data_sebelum,
    COALESCE(CAST(data_sesudah AS CHAR), 'NULL')    AS data_sesudah,
    DATE_FORMAT(waktu, '%d/%m/%Y %H:%i:%s')         AS waktu,
    user_db,
    COALESCE(ip_info, 'LOCALHOST')                  AS ip_info
FROM audit_log
ORDER BY log_id DESC
LIMIT 10;

-- Test Modul 2
INSERT INTO orders (customer_id, tanggal_order, status, total_harga)
VALUES (1, NOW(), 'pending', 500000);

UPDATE orders SET status = 'proses' WHERE order_id = LAST_INSERT_ID();

UPDATE products SET harga = 90000, stok = 45 WHERE product_id = 1;

SELECT * FROM audit_log ORDER BY log_id DESC LIMIT 5;


-- ============================================================
-- MODUL 3: STORED PROCEDURE SUITE
-- ============================================================

DROP PROCEDURE IF EXISTS sp_proses_order_baru;
-- Procedure 1: Proses Order Baru (TRANSACTION lengkap)
DELIMITER //

CREATE PROCEDURE sp_proses_order_baru(
    IN p_customer_id  INT,
    IN p_product_id   INT,
    IN p_qty          INT,
    OUT p_order_id    INT,
    OUT p_total       DECIMAL(12,2)
)
BEGIN
    DECLARE v_harga   DECIMAL(12,2);
    DECLARE v_stok    INT;
    
    -- Rollback otomatis jika terjadi error tak terduga
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Kunci baris produk untuk menghindari race condition
    SELECT stok, harga
    INTO v_stok, v_harga
    FROM products
    WHERE product_id = p_product_id
    FOR UPDATE;
    
    -- Validasi
    IF v_stok IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Produk tidak ditemukan!';
    END IF;

    IF p_qty <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Qty harus lebih dari 0!';
    END IF;

    -- Buat order
    SET p_total = v_harga * p_qty;

    INSERT INTO orders (customer_id, tanggal_order, status, total_harga)
    VALUES (p_customer_id, NOW(), 'pending', p_total);

    SET p_order_id = LAST_INSERT_ID();

    INSERT INTO order_items (order_id, product_id, quantity, harga_satuan)
    VALUES (p_order_id, p_product_id, p_qty, v_harga);

    -- Kurangi stok
    UPDATE products
    SET stok = stok - p_qty
    WHERE product_id = p_product_id;

    COMMIT;
END //
DELIMITER ;

-- Procedure 2: Laporan Periode
DROP PROCEDURE IF EXISTS sp_laporan_periode;

DELIMITER //
CREATE PROCEDURE sp_laporan_periode(
    IN p_tgl_awal   DATE,
    IN p_tgl_akhir  DATE
)
BEGIN
    IF p_tgl_awal > p_tgl_akhir THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tanggal awal tidak boleh lebih besar dari tanggal akhir!';
    END IF;

    SELECT
        COUNT(o.order_id)                   AS jumlah_order,
        COALESCE(ROUND(SUM(o.total_harga), 2), 0)   AS total_revenue,
        COALESCE(ROUND(AVG(o.total_harga), 2), 0)   AS aov,
        COALESCE((
            SELECT CONCAT(p.nama_produk, ' (', SUM(oi2.quantity), ' unit)')
            FROM order_items AS oi2
            JOIN orders AS o2       ON oi2.order_id   = o2.order_id
            JOIN products AS p      ON oi2.product_id = p.product_id
            WHERE o2.status = 'selesai'
              AND o2.tanggal_order BETWEEN p_tgl_awal AND p_tgl_akhir
            GROUP BY p.product_id, p.nama_produk
            ORDER BY SUM(oi2.quantity) DESC
            LIMIT 1
        ), 'Tidak ada data')                AS produk_terlaris
    FROM orders AS o
    WHERE o.status = 'selesai'
      AND o.tanggal_order BETWEEN p_tgl_awal AND p_tgl_akhir;
END //
DELIMITER ;

-- Procedure 3: Update Status Order (State Machine)
DROP PROCEDURE IF EXISTS sp_update_status_order;

DELIMITER //

CREATE PROCEDURE sp_update_status_order(
    IN p_order_id       INT,
    IN p_status_baru    VARCHAR(20)
)
BEGIN
    DECLARE v_status_lama VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT status INTO v_status_lama
    FROM orders
    WHERE order_id = p_order_id
    FOR UPDATE;

    -- Validasi order ada (dengan ROW_COUNT untuk keamanan ekstra)
    IF ROW_COUNT() = 0 OR v_status_lama IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order tidak ditemukan!';
    END IF;

    -- Validasi status tidak sama
    IF v_status_lama = p_status_baru THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Status sudah sama, tidak perlu update!';
    END IF;

    -- Validasi transisi yang diizinkan
    IF      v_status_lama = 'pending' AND p_status_baru = 'proses'   THEN
        UPDATE orders SET status = p_status_baru WHERE order_id = p_order_id;
    ELSEIF  v_status_lama = 'proses'  AND p_status_baru = 'selesai'  THEN
        UPDATE orders SET status = p_status_baru WHERE order_id = p_order_id;
    ELSEIF  v_status_lama = 'pending' AND p_status_baru = 'batal'    THEN
        UPDATE orders SET status = p_status_baru WHERE order_id = p_order_id;
    
    END IF;

    COMMIT;
END //

DELIMITER ;

-- Test Modul 3
CALL sp_proses_order_baru(1, 1, 2, @oid, @total);
SELECT @oid AS order_id_baru, @total AS total_harga;

CALL sp_update_status_order(@oid, 'proses');
CALL sp_update_status_order(@oid, 'selesai');

CALL sp_laporan_periode('2024-01-01', '2024-12-31');

-- ============================================================
-- MODUL 4: ANALISIS ADVANCED DENGAN CTE
-- ============================================================

-- A. Analisis Kohort Retensi
-- Mengelompokkan customer berdasarkan bulan pertama order, lalu menghitung berapa % yang masih aktif di bulan berikutnya

WITH customer_cohort AS (
    SELECT
        customer_id,
        DATE_FORMAT(MIN(tanggal_order), '%Y%m')     AS bulan_bergabung
    FROM orders
    WHERE status = 'selesai'
    GROUP BY customer_id
),
customer_activity AS (
    SELECT
        customer_id,
        DATE_FORMAT(tanggal_order, '%Y%m')          AS bulan_aktif
    FROM orders
    WHERE status = 'selesai'
    GROUP BY customer_id, DATE_FORMAT(tanggal_order, '%Y%m')
),
cohort_map AS (
    SELECT
        c.bulan_bergabung,
        c.customer_id,
        PERIOD_DIFF(a.bulan_aktif, c.bulan_bergabung)   AS jarak_bulan
    FROM customer_cohort AS c
    JOIN customer_activity AS a ON c.customer_id = a.customer_id
),
cohort_retention AS (
    SELECT
        bulan_bergabung,
        jarak_bulan,
        COUNT(DISTINCT customer_id)                  AS jumlah_aktif
    FROM cohort_map
    GROUP BY bulan_bergabung, jarak_bulan
)
SELECT
    bulan_bergabung,
    MAX(CASE WHEN jarak_bulan = 0 THEN jumlah_aktif END)    AS customer_awal,
    MAX(CASE WHEN jarak_bulan = 1 THEN jumlah_aktif END)    AS aktif_bulan_berikutnya,
    ROUND(
        MAX(CASE WHEN jarak_bulan = 1 THEN jumlah_aktif END) * 100.0 /
        NULLIF(MAX(CASE WHEN jarak_bulan = 0 THEN jumlah_aktif END), 0)
    , 2)                                                    AS retensi_persen
FROM cohort_retention
GROUP BY bulan_bergabung
ORDER BY bulan_bergabung;

-- b. Analisis Basket (product Pairing)
-- Mencari pasangan produk yang paling sering dibeli dalam satu order yang sama menggunakan SELF JOIN

WITH valid_orders AS (
    -- 1️. Filter hanya order yang selesai
    SELECT order_id FROM orders WHERE status = 'selesai'
),
product_pairs AS (
    -- 2️. SELF JOIN pada order_items untuk cari pasangan dalam 1 order
    SELECT 
        a.product_id AS prod_a,
        b.product_id AS prod_b
    FROM order_items a
    JOIN order_items b ON a.order_id = b.order_id
    JOIN valid_orders v ON a.order_id = v.order_id
    WHERE a.product_id < b.product_id  -- Hindari duplikat (A,B) & (B,A) serta (A,A)
),
pair_frequency AS (
    -- 3️. Hitung frekuensi kemunculan pasangan
    SELECT prod_a, prod_b, COUNT(*) AS frekuensi_bersama
    FROM product_pairs
    GROUP BY prod_a, prod_b
)
-- Gabungkan dengan nama produk & urutkan
SELECT 
    p1.nama_produk AS produk_a,
    p2.nama_produk AS produk_b,
    pf.frekuensi_bersama
FROM pair_frequency pf
JOIN products p1 ON pf.prod_a = p1.product_id
JOIN products p2 ON pf.prod_b = p2.product_id
ORDER BY pf.frekuensi_bersama DESC
LIMIT 10;

-- C. Moving Average Revenue (3 bulan)
-- Menghitung rata-rata bergulir 3 bulan terakhir menggunakan window frame eksplisit
WITH monthly_revenue AS (
    -- 1️. Agregasi revenue per bulan
    SELECT 
        YEAR(tanggal_order) AS tahun,
        MONTH(tanggal_order) AS bulan,
        SUM(total_harga) AS revenue
    FROM orders 
    WHERE status = 'selesai'
    GROUP BY YEAR(tanggal_order), MONTH(tanggal_order)
),
moving_avg_calc AS (
    -- 2️. Hitung Moving Average dengan frame eksplisit
    SELECT 
        CONCAT(tahun, '-', LPAD(bulan, 2, '0')) AS periode,
        revenue,
        ROUND(
            AVG(revenue) OVER (
                ORDER BY tahun, bulan 
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            ), 2
        ) AS ma_3_bulan
    FROM monthly_revenue
)
-- Tampilkan hasil
SELECT periode, revenue, ma_3_bulan
FROM moving_avg_calc
ORDER BY periode;

-- B. Analisis Basket (Product Pairing)
WITH valid_orders AS (
    SELECT order_id FROM orders WHERE status = 'selesai'
),
product_pairs AS (
    SELECT
        a.product_id    AS prod_a,
        b.product_id    AS prod_b
    FROM order_items a
    JOIN order_items b  ON a.order_id    = b.order_id
                       AND a.product_id < b.product_id
    JOIN valid_orders v ON a.order_id    = v.order_id
),
pair_frequency AS (
    SELECT prod_a, prod_b, COUNT(*) AS frekuensi_bersama
    FROM product_pairs
    GROUP BY prod_a, prod_b
)
SELECT
    p1.nama_produk  AS produk_a,
    p2.nama_produk  AS produk_b,
    pf.frekuensi_bersama
FROM pair_frequency pf
JOIN products p1 ON pf.prod_a = p1.product_id
JOIN products p2 ON pf.prod_b = p2.product_id
ORDER BY pf.frekuensi_bersama DESC
LIMIT 10;

-- C. Moving Average Revenue 3 Bulan
WITH monthly_revenue AS (
    SELECT
        YEAR(tanggal_order)     AS tahun,
        MONTH(tanggal_order)    AS bulan,
        SUM(total_harga)        AS revenue
    FROM orders
    WHERE status = 'selesai'
    GROUP BY YEAR(tanggal_order), MONTH(tanggal_order)
),
moving_avg_calc AS (
    SELECT
        CONCAT(tahun, '-', LPAD(bulan, 2, '0'))     AS periode,
        revenue,
        ROUND(
            AVG(revenue) OVER (
                ORDER BY tahun, bulan
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            ), 2
        )                                           AS ma_3_bulan
    FROM monthly_revenue
)
SELECT periode, revenue, ma_3_bulan
FROM moving_avg_calc
ORDER BY periode;

# Tanpa index, CTE berantai + window function akan lambat pada data >100k baris:
CREATE INDEX idx_orders_cust_date ON orders(customer_id, tanggal_order, status);
CREATE INDEX idx_oi_order_prod ON order_items(order_id, product_id);


-- ============================================================
-- MODUL 5: DASHBOARD EKSEKUTIF
-- ============================================================

-- 1. Top 3 Customer (FRM) dengan Monetary Tertinggi
--  Customer Champion: recency ≤30 hari, frequency ≥2, monetary tertinggi
SELECT
    nama,
    kota,
    recency,
    frequency,
    CONCAT('Rp ', FORMAT(monetary, 0))  AS monetary_formatted,
    segmen_rfm
FROM vw_kinerja_customer
WHERE segmen_rfm = 'Champion'
ORDER BY monetary DESC
LIMIT 3;

-- 2. Star Performer Produk per kategori
--  Produk Star: ranking #1 per kategori berdasarkan revenue
SELECT
    kategori,
    nama_produk,
    total_qty_terjual,
    CONCAT('Rp ', FORMAT(total_revenue, 0))  AS revenue_formatted,
    ranking_per_kategori
FROM vw_kinerja_produk
WHERE ranking_per_kategori = 1
  AND total_revenue > 0
ORDER BY total_revenue DESC;

-- 3. Bulan dengan Growth Tertinggi dan Terendah
-- Catatan: MySQL tidak support NULLS LAST/FIRST, pakai CASE WHEN
WITH growth_analysis AS (
    SELECT
        periode,
        total_revenue,
        pertumbuhan_persen,
        ROW_NUMBER() OVER (
            ORDER BY
                CASE WHEN pertumbuhan_persen IS NULL THEN 1 ELSE 0 END,
                pertumbuhan_persen DESC
        ) AS rank_naik,
        ROW_NUMBER() OVER (
            ORDER BY
                CASE WHEN pertumbuhan_persen IS NULL THEN 1 ELSE 0 END,
                pertumbuhan_persen ASC
        ) AS rank_turun
    FROM vw_tren_bulanan
    WHERE pertumbuhan_persen IS NOT NULL
)
SELECT 'Growth Tertinggi'   AS metrik,
       periode,
       CONCAT(pertumbuhan_persen, '%') AS nilai
FROM growth_analysis WHERE rank_naik = 1
UNION ALL
SELECT 'Growth Terendah',
       periode,
       CONCAT(pertumbuhan_persen, '%')
FROM growth_analysis WHERE rank_turun = 1;

-- 4. Total Revenue Kumulatif Sampai Hari Ini
SELECT
    CONCAT('Rp ', FORMAT(MAX(running_total), 0))   	 AS total_revenue_kumulatif,
    MAX(periode)                                     AS periode_terakhir,
    COUNT(*)                                         AS total_bulan_dianalisis
FROM vw_tren_bulanan;



-- 5. Customer At Risk (tidak order lebih dari 60 hari)
-- Customer At Risk: recency > 60 hari, masih berpotensi direaktivasi
SELECT
    nama,
    kota,
    recency,
    frequency,
    CONCAT('Rp ', FORMAT(monetary, 0))  AS historical_monetary,
    segmen_rfm,
    CASE
        WHEN monetary > 1000000     THEN 'Prioritas Tinggi — Hubungi Langsung'
        WHEN frequency >= 2         THEN 'Email Campaign'
        ELSE                             'Push Notification'
    END AS rekomendasi_aksi
FROM vw_kinerja_customer
WHERE segmen_rfm = 'At Risk'
ORDER BY monetary DESC, recency ASC;


-- ============================================================
-- MODUL 6: SISTEM PROTEKSI DATA
-- ============================================================

-- Trigger 1: BEFORE DELETE ON orders (proteksi data finansial)
DROP TRIGGER IF EXISTS trg_protect_finished_orders;

DELIMITER //
CREATE TRIGGER trg_protect_finished_orders
BEFORE DELETE ON orders
FOR EACH ROW
BEGIN
    IF OLD.status = 'selesai' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Proteksi: Order SELESAI tidak boleh dihapus. Gunakan status batal untuk pembatalan.';
    END IF;
END //
DELIMITER ;


-- Trigger 2: BEFORE INSERT ON order_items (validasi stok real-time)
DROP TRIGGER IF EXISTS trg_validate_stock_insert;

DELIMITER //
CREATE TRIGGER trg_validate_stock_insert
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE v_stok INT;

    SELECT stok INTO v_stok
    FROM products
    WHERE product_id = NEW.product_id;

    IF v_stok IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Produk tidak ditemukan!';
    ELSEIF v_stok < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = CONCAT(
            'Stok tidak mencukupi! Tersedia: ', v_stok,
            ', Dibutuhkan: ', NEW.quantity
        );
    END IF;
END //
DELIMITER ;


-- Trigger 3: AFTER INSERT ON order_items (auto-update total_harga di orders)
DROP TRIGGER IF EXISTS trg_auto_update_total_harga;

DELIMITER //
CREATE TRIGGER trg_auto_update_total_harga
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders
    SET total_harga = (
        SELECT COALESCE(SUM(quantity * harga_satuan), 0)
        FROM order_items
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END //
DELIMITER ;

-- Test Modul 6
INSERT INTO orders (customer_id, tanggal_order, status)
VALUES (1, NOW(), 'pending');
SET @test_order = LAST_INSERT_ID();

-- Test valid: stok cukup
INSERT INTO order_items (order_id, product_id, quantity, harga_satuan)
VALUES (@test_order, 2, 1, 250000);

-- Cek total_harga otomatis terupdate
SELECT order_id, total_harga FROM orders WHERE order_id = @test_order;

-- Test invalid: coba hapus order selesai
UPDATE orders SET status = 'selesai' WHERE order_id = @test_order;
DELETE FROM orders WHERE order_id = @test_order;
-- Output: Error 1644 — Proteksi: Order SELESAI tidak boleh dihapus


-- ============================================================
-- MODUL 7: LAPORAN BULANAN LENGKAP (5 Result Set)
-- ============================================================
DROP PROCEDURE IF EXISTS sp_laporan_bulanan_lengkap;


DELIMITER //
CREATE PROCEDURE sp_laporan_bulanan_lengkap(
    IN p_tahun  INT,
    IN p_bulan  INT
)
BEGIN
    DECLARE v_tgl_awal      DATE;
    DECLARE v_tgl_akhir     DATE;
    DECLARE v_tgl_prev      DATE;

    -- Validasi input
    IF p_bulan < 1 OR p_bulan > 12 OR p_tahun < 2000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Parameter tahun/bulan tidak valid!';
    END IF;

    -- Hitung rentang tanggal
    SET v_tgl_awal  = STR_TO_DATE(CONCAT(p_tahun, '-', LPAD(p_bulan, 2, '0'), '-01'), '%Y-%m-%d');
    SET v_tgl_akhir = LAST_DAY(v_tgl_awal);
    SET v_tgl_prev  = v_tgl_awal - INTERVAL 1 MONTH;

    -- RESULT 1: Ringkasan Bulan
    SELECT
        COUNT(order_id)                                             AS total_order,
        COALESCE(ROUND(SUM(total_harga), 2), 0)                    AS total_revenue,
        COALESCE(ROUND(AVG(total_harga), 2), 0)                    AS aov,
        ROUND(
            COUNT(CASE WHEN status = 'selesai' THEN 1 END) * 100.0
            / NULLIF(COUNT(order_id), 0), 2
        )                                                           AS conversion_rate_pct
    FROM orders
    WHERE YEAR(tanggal_order)  = p_tahun
      AND MONTH(tanggal_order) = p_bulan;

    -- RESULT 2: Top 5 Produk Bulan Ini
    SELECT
        p.nama_produk,
        p.kategori,
        SUM(oi.quantity)                        AS qty_terjual,
        ROUND(SUM(oi.quantity * oi.harga_satuan), 2) AS revenue
    FROM orders o
    JOIN order_items oi  ON o.order_id    = oi.order_id
    JOIN products p      ON oi.product_id = p.product_id
    WHERE o.status = 'selesai'
      AND YEAR(o.tanggal_order)  = p_tahun
      AND MONTH(o.tanggal_order) = p_bulan
    GROUP BY p.product_id, p.nama_produk, p.kategori
    ORDER BY revenue DESC
    LIMIT 5;

    -- RESULT 3: Top 5 Customer Bulan Ini
    SELECT
        c.nama,
        c.kota,
        COUNT(o.order_id)               AS jumlah_order,
        ROUND(SUM(o.total_harga), 2)    AS total_belanja
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.status = 'selesai'
      AND YEAR(o.tanggal_order)  = p_tahun
      AND MONTH(o.tanggal_order) = p_bulan
    GROUP BY c.customer_id, c.nama, c.kota
    ORDER BY total_belanja DESC
    LIMIT 5;

    -- RESULT 4: Breakdown Kategori + Growth vs Bulan Sebelumnya
    WITH curr_data AS (
        SELECT
            p.kategori,
            SUM(oi.quantity * oi.harga_satuan)  AS revenue_ini
        FROM orders o
        JOIN order_items oi  ON o.order_id    = oi.order_id
        JOIN products p      ON oi.product_id = p.product_id
        WHERE o.status = 'selesai'
          AND YEAR(o.tanggal_order)  = p_tahun
          AND MONTH(o.tanggal_order) = p_bulan
        GROUP BY p.kategori
    ),
    prev_data AS (
        SELECT
            p.kategori,
            SUM(oi.quantity * oi.harga_satuan)  AS revenue_lalu
        FROM orders o
        JOIN order_items oi  ON o.order_id    = oi.order_id
        JOIN products p      ON oi.product_id = p.product_id
        WHERE o.status = 'selesai'
          AND YEAR(o.tanggal_order)  = YEAR(v_tgl_prev)
          AND MONTH(o.tanggal_order) = MONTH(v_tgl_prev)
        GROUP BY p.kategori
    )
    SELECT
        c.kategori,
        COALESCE(c.revenue_ini, 0)      AS revenue_bulan_ini,
        COALESCE(p.revenue_lalu, 0)     AS revenue_bulan_lalu,
        CASE
            WHEN COALESCE(p.revenue_lalu, 0) = 0 THEN NULL
            ELSE ROUND(
                (c.revenue_ini - p.revenue_lalu) / p.revenue_lalu * 100, 2
            )
        END                             AS growth_persen
    FROM curr_data c
    LEFT JOIN prev_data p ON c.kategori = p.kategori
    ORDER BY c.revenue_ini DESC;

    -- RESULT 5: Customer Baru Bulan Ini
    SELECT
        customer_id,
        nama,
        email,
        kota,
        tanggal_daftar
    FROM customers
    WHERE YEAR(tanggal_daftar)  = p_tahun
      AND MONTH(tanggal_daftar) = p_bulan
    ORDER BY tanggal_daftar DESC;

END //
DELIMITER ;

-- Test Modul 7
CALL sp_laporan_bulanan_lengkap(2024, 1);

-- Call test
CALL sp_laporan_bulanan_lengkap(2024, 1);
