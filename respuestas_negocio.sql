SET search_path TO public;
SELECT table_name, column_name, data_type FROM information_schema.COLUMNS WHERE table_schema = 'public';


--Listar los usuarios que cumplan años el día de hoy cuya cantidad de ventas
--realizadas en enero 2020 sea superior a 1500.

select c.nombre, c.apellido, COUNT(o.ORDER_ID) as total_ventas
from customer c join seller s on c.user_id = s.user_id join orders o on o.seller_id = s.seller_id 
where extract(month from o.order_date) = 1 and extract(month from c.fecha_nacimiento) = extract(month from current_date) and extract(day from c.fecha_nacimiento) = extract(day from current_date) group by c.nombre, c.apellido 
having COUNT (o.order_id) > 1500;  


/*Por cada mes del 2020, se solicita el top 5 de usuarios que más vendieron($) en la
categoría Celulares. Se requiere el mes y año de análisis, nombre y apellido del
vendedor, cantidad de ventas realizadas, cantidad de productos vendidos y el monto
total transaccionado.
Se puso ca.categoria_id = 1 porque celulares, en el ejemplo, se puso en el primer lugar*/

WITH top_5 AS (
    SELECT 
        seller_id, 
        EXTRACT(MONTH FROM order_date) AS mes, 
        SUM(total_bill) AS total_recaudado,
        ROW_NUMBER() OVER (PARTITION BY EXTRACT(MONTH FROM order_date) ORDER BY SUM(total_bill) DESC) AS rn
    FROM ORDERS
    GROUP BY seller_id, EXTRACT(MONTH FROM order_date)
)
SELECT 
    c.nombre, 
    c.apellido, 
    t.mes, 
    EXTRACT(YEAR FROM o.order_date) AS año, 
    COUNT(o.order_id) AS total_pedidos, 
    SUM(i.cantidad) as "Cantidad productos vendidos",
    SUM(o.total_bill) AS total_recaudado
FROM customer c 
JOIN seller s ON c.user_id = s.user_id 
JOIN orders o ON o.seller_id = s.seller_id
join ITEM i on i.order_id = o.order_id
join PRODUCTO p on p.producto_id = i.producto_id
join CATEGORIA ca on ca.categoria_id = p.categoria_id 
JOIN top_5 t ON o.seller_id = t.seller_id AND EXTRACT(MONTH FROM o.order_date) = t.mes
WHERE EXTRACT(YEAR FROM o.order_date) = 2020 and ca.categoria_id = 1
AND t.rn <= 5
GROUP BY t.mes, año, c.nombre, c.apellido 
ORDER BY mes, total_recaudado desc;

/* Cree la tabla FINALDIA y cree un procedure que permite cargar items automaticamente teniendo en 
cuenta los valores de la tabla productos */

create procedure estadofinal ()
language plpgsql
as $$
begin
	INSERT INTO FINALDIA (NOMBRE, PRODUCTO_ID, PRECIO, FECHA)
	SELECT NOMBRE, PRODUCTO_ID, PRECIO, CURRENT_DATE
	FROM PRODUCTO;
end;
$$;






















