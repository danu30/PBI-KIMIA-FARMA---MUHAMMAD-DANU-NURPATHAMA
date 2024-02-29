CREATE TABLE KimiaFarma.analisistransaksiKimiaFarma AS
SELECT 
    ft.transaction_id,
    ft.date,
    kc.branch_id,
    kc.branch_name,
    kc.kota,
    kc.provinsi,
    kc.rating AS rating_cabang,
    ft.customer_name,
    inv.product_id,
    inv.product_name,
    ft.price AS actual_price,
    ft.discount_percentage,
    ft.rating AS rating_transaksi,
    ft.price * (1 - ft.discount_percentage / 100) AS nett_sales,
    CASE
        WHEN ft.price <= 50000 THEN 0.1
        WHEN ft.price > 50000 AND ft.price <= 100000 THEN 0.15
        WHEN ft.price > 100000 AND ft.price <= 300000 THEN 0.2
        WHEN ft.price > 300000 AND ft.price <= 500000 THEN 0.25
        WHEN ft.price > 500000 THEN 0.3
    END AS persentase_gross_laba,
    (ft.price * (1 - ft.discount_percentage / 100)) * 
    CASE
        WHEN ft.price <= 50000 THEN 0.1
        WHEN ft.price > 50000 AND ft.price <= 100000 THEN 0.15
        WHEN ft.price > 100000 AND ft.price <= 300000 THEN 0.2
        WHEN ft.price > 300000 AND ft.price <= 500000 THEN 0.25
        WHEN ft.price > 500000 THEN 0.3
    END AS nett_profit
FROM 
    KimiaFarma.finaltransaction ft
JOIN 
    KimiaFarma.kantorcabang kc ON ft.branch_id = kc.branch_id
JOIN 
    KimiaFarma.inventory inv ON ft.product_id = inv.product_id AND ft.branch_id = inv.branch_id
JOIN 
    KimiaFarma.product p ON inv.product_id = p.product_id;

CREATE TABLE KimiaFarma.cabang_rating_kontradiktif AS
SELECT 
    branch_name,
    AVG(rating_cabang) AS avg_rating_cabang,
    AVG(rating_transaksi) AS avg_rating_transaksi
FROM 
    KimiaFarma.analisistransaksiKimiaFarma
GROUP BY 
    branch_name
HAVING 
    AVG(rating_cabang) IS NOT NULL AND AVG(rating_transaksi) IS NOT NULL
ORDER BY 
    avg_rating_cabang DESC, avg_rating_transaksi
LIMIT 5;

CREATE TABLE KimiaFarma.nett_sales_provinsi AS
SELECT 
    provinsi,
    SUM(nett_sales) AS total_nett_sales
FROM 
    KimiaFarma.analisistransaksiKimiaFarma
GROUP BY 
    provinsi
ORDER BY 
    total_nett_sales DESC
LIMIT 10;

CREATE TABLE KimiaFarma.pendapatan_tahunan AS
SELECT 
    EXTRACT(YEAR FROM date) AS tahun,
    SUM(nett_sales) AS total_nett_sales
FROM 
    KimiaFarma.analisistransaksiKimiaFarma
GROUP BY 
    tahun
ORDER BY 
    tahun;

CREATE TABLE KimiaFarma.profit_provinsi_geo AS
SELECT 
    provinsi,
    SUM(nett_profit) AS total_profit
FROM 
    KimiaFarma.analisistransaksiKimiaFarma
GROUP BY 
    provinsi;

CREATE TABLE KimiaFarma.total_transaksi_provinsi AS
SELECT 
    provinsi,
    COUNT(transaction_id) AS total_transaksi
FROM 
    KimiaFarma.analisistransaksiKimiaFarma
GROUP BY 
    provinsi
ORDER BY 
    total_transaksi DESC
LIMIT 10;