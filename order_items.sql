CREATE TABLE order_items (
	item_id			INT NOT NULL PRIMARY KEY,
	order_id		INT NOT NULL,
	product_id		INT NOT NULL,
	quantity		INT NOT NULL DEFAULT 1,
	harga_satuan	DECIMAL(12,2) NOT NULL,
	subtotal        DECIMAL(12,2) GENERATED ALWAYS AS (quantity * harga_satuan) STORED,

		CONSTRAINT fk_order_items_orders
			FOREIGN KEY (order_id) REFERENCES orders(order_id)
			ON DELETE CASCADE
			ON UPDATE CASCADE,
    
		CONSTRAINT fk_order_items_products
			FOREIGN KEY (product_id) REFERENCES products(product_id)
			ON DELETE CASCADE
			ON UPDATE CASCADE
)ENGINE = InnoDB;

SHOW CREATE TABLE order_items;
