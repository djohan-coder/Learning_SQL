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