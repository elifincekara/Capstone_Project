--CAPSTONE PROJECT-ELIF INCEKARA

--Null Değerleri Doldurma
UPDATE customers
SET region = COALESCE(region, 'Bolge Atanmamis');

UPDATE customers
SET fax = COALESCE(fax, 'Fax Atanmamis');

UPDATE employees
SET region = COALESCE(region, 'Bolge Atanmamis');

UPDATE orders
SET ship_region = COALESCE(ship_region, 'Bolge Atanmamis');

UPDATE orders
SET ship_postal_code = COALESCE(ship_postal_code, 'Atanmamis');


--MÜŞTERİ SEGMENTASYON ANALİZİ
--1.Coğrafi Segmentasyon(Pythonda görselleştirildi)
--Ulke
SELECT
    country,
    COUNT(customer_id) AS CustomerCount
FROM 
    customers
GROUP BY 
    country
ORDER BY 
    CustomerCount DESC;
--Sehir	
SELECT 
    city,
    COUNT(customer_id) AS CustomerCity
FROM 
    customers
GROUP BY 
    city
ORDER BY 
    CustomerCity DESC;
	
--2. Müşteri Satın Alma Alışkanlıkları(Pythonda görselleştirildi)
 
SELECT 
    c.customer_id,
    c.contact_name,
    COUNT(o.order_id) AS ToplamSiparis,
    ROUND(SUM(od.quantity * od.unit_price)::numeric, 2) AS ToplamHarcama
	FROM
	customers c 
INNER JOIN 
    orders o ON c.customer_id = o.customer_id
INNER JOIN 
    order_details od ON o.order_id = od.order_id
GROUP BY 
    c.customer_id, c.contact_name;
	
	
--SALES KPIs (SATIŞ TEMEL PERFORMANS GÖSTERGELERİ)
--1.Ülkelere Göre Toplam Gelir
SELECT
    c.country,
        ROUND(SUM(od.unit_price * od.quantity)::numeric, 2) AS toplam_gelir
FROM
    customers c
JOIN
    orders o ON c.customer_id = o.customer_id
JOIN
    order_details od ON o.order_id = od.order_id
GROUP BY
    c.country
ORDER BY
    toplam_gelir DESC;
--2.Ülkelere Göre Toplam Gelir ve Satış Hacmi
SELECT
    c.country,
    ROUND(SUM(od.unit_price * od.quantity)::numeric, 2) AS toplam_gelir,
    SUM(od.quantity) AS satis_hacmi
FROM
    customers c
JOIN
    orders o ON c.customer_id = o.customer_id
JOIN
    order_details od ON o.order_id= od.order_id
GROUP BY
    c.country
ORDER BY
    toplam_gelir DESC;
--3.Yıllara Göre Toplam Gelir ve Satış Hacmi 
SELECT 
    DATE_PART('year', o.order_date) AS siparis_yili,
    CAST(SUM(od.unit_price * od.quantity) AS NUMERIC(10, 2)) AS toplam_gelir,
    SUM(od.quantity) AS toplam_miktar
FROM 
    orders o
JOIN 
    order_details od ON o.order_id = od.order_id
GROUP BY 
    DATE_PART('year', o.order_date)
ORDER BY 
    siparis_yili;
--4.Aylara Göre Toplam Gelir ve Satış Hacmi
SELECT 
    DATE_PART('year', o.order_date) AS siparis_yili,
    DATE_PART('month', o.order_date) AS siparis_ayi,
    CAST(SUM(od.unit_price * od.quantity) AS NUMERIC(10, 2)) AS toplam_gelir,
    SUM(od.quantity) AS toplam_miktar
FROM 
    orders o
JOIN 
    order_details od ON o.order_id = od.order_id
GROUP BY 
    DATE_PART('year', o.order_date),
    DATE_PART('month', o.order_date)
ORDER BY 
    siparis_yili, siparis_ayi;

--5.Günlere Göre Toplam Gelir ve Satış Hacmi 
SELECT 
    DATE_PART('year', o.order_date) AS siparis_yili,
    DATE_PART('month', o.order_date) AS siparis_ayi,
    DATE_PART('day', o.order_date) AS siparis_gunu,
    TO_CHAR(o.order_date, 'YYYY-MM-DD') AS siparis_tarihi,
    CAST(SUM(od.unit_price * od.quantity) AS NUMERIC(10, 2)) AS toplam_gelir,
    SUM(od.quantity) AS toplam_miktar
FROM 
    orders o
JOIN 
    order_details od ON o.order_id = od.order_id
GROUP BY 
    DATE_PART('year', o.order_date),
    DATE_PART('month', o.order_date),
    DATE_PART('day', o.order_date),
    TO_CHAR(o.order_date, 'YYYY-MM-DD')
ORDER BY 
    siparis_yili, siparis_ayi, siparis_gunu;
--6.Çeyreklere Göre Toplam Gelir ve Satış Hacmi 
SELECT 
    CASE 
        WHEN DATE_PART('month', o.order_date) BETWEEN 1 AND 3 THEN 'Q1'
        WHEN DATE_PART('month', o.order_date) BETWEEN 4 AND 6 THEN 'Q2'
        WHEN DATE_PART('month', o.order_date) BETWEEN 7 AND 9 THEN 'Q3'
        ELSE 'Q4'
    END AS quarter,
    CAST(SUM(od.unit_price * od.quantity) AS NUMERIC(10, 2)) AS toplam_gelir,
    SUM(od.quantity) AS toplam_miktar,
    CAST(SUM(od.unit_price * od.quantity) / COUNT(DISTINCT DATE_TRUNC('year', o.order_date)) AS NUMERIC(10, 2)) AS yillik_ortalama_gelir
FROM 
    orders o
JOIN 
    order_details od ON o.order_id = od.order_id
WHERE 
    DATE_PART('year', o.order_date) = 1997
GROUP BY 
    quarter
ORDER BY 
    quarter;
--KATEGORİ BAZLI GELİR ANALİZİ
SELECT 
    c.category_name,
    ROUND(SUM(od.unit_price * od.quantity) ::numeric,2) AS total_revenue
FROM 
    order_details od
JOIN 
    products p ON od.product_id = p.product_id
JOIN 
    categories c ON p.category_id = c.category_id
GROUP BY 
    c.category_name
ORDER BY 
    total_revenue DESC;
--ÜRÜN BAZLI GELİR ANALİZİ
SELECT 
    p.product_name,
   ROUND(SUM(od.unit_price * od.quantity)::numeric,2) AS total_revenue
FROM 
    order_details od
JOIN 
    products p ON od.product_id = p.product_id
GROUP BY 
    p.product_name
ORDER BY 
    total_revenue DESC;
--Kategorisini de yanında görelim
SELECT 
    p.product_name,
    c.category_name,
    ROUND(SUM(od.unit_price * od.quantity) ::numeric,2) AS total_revenue
FROM 
    order_details od
JOIN 
    products p ON od.product_id = p.product_id
JOIN 
    categories c ON p.category_id = c.category_id
GROUP BY 
    p.product_name, c.category_name
ORDER BY 
    total_revenue DESC;
	
--ÜRÜN TREND ANALİZİ
--En Çok Satılan İlk 10 Ürün
SELECT 
    p.product_name,
    SUM(od.quantity) AS total_quantity
FROM 
    order_details od
JOIN 
    products p ON od.product_id = p.product_id
GROUP BY 
    p.product_name
ORDER BY 
    total_quantity DESC
LIMIT 10;

--Yıllara Göre
SELECT 
    p.product_name,
    COALESCE(SUM(od.quantity) FILTER (WHERE EXTRACT(year FROM o.order_date) = 1996), 0) AS total_quantity_1996,
    COALESCE(SUM(od.quantity) FILTER (WHERE EXTRACT(year FROM o.order_date) = 1997), 0) AS total_quantity_1997,
    COALESCE(SUM(od.quantity) FILTER (WHERE EXTRACT(year FROM o.order_date) = 1998), 0) AS total_quantity_1998
FROM 
    orders o
JOIN 
    order_details od ON o.order_id = od.order_id
JOIN 
    products p ON od.product_id = p.product_id
GROUP BY 
    p.product_name
ORDER BY 
    p.product_name;	
--ÇALIŞAN PERFORMANS ANALİZİ 
SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS isim,
    e.title_of_courtesy AS nezaket_unvani,
    e.title AS unvan,
    COUNT(DISTINCT o.order_id) AS toplam_siparis,
    SUM(od.quantity) AS satilan_toplam_miktar,
    ROUND(SUM(od.unit_price * od.quantity)::numeric, 2) AS toplam_gelir,
    ROUND(SUM(od.unit_price * od.quantity * od.discount)::numeric, 2) AS toplam_indirim,
    ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS indirim_dahil_toplam_satis_tutari
FROM
    employees e
JOIN
    orders o ON e.employee_id = o.employee_id
JOIN
    order_details od ON o.order_id = od.order_id
GROUP BY
    e.employee_id,
    isim,
    e.title_of_courtesy,
    e.title
ORDER BY
    satilan_toplam_miktar DESC;























	

