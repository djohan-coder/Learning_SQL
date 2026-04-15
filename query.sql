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
	c.nama AS naam_customer,
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
		