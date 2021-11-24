--We are running an experiment at an item-level, which means all users who visit will see the same page, but the layout of different item pages may differ.
--Compare this table to the assignment events we captured for user_level_testing.
--Does this table have everything you need to compute metrics like 30-day view-binary?

SELECT 
  * 
FROM 
  dsv1069.final_assignments_qa;
  
  --No, the date field is required.





  
  --Reformat the final_assignments_qa to look like the final_assignments table, filling in any missing values with a placeholder of the appropriate data type.


(SELECT item_id,
        test_a   AS test_assignment,
       'test_a'  AS test_number,
        now()    AS test_start_date
FROM dsv1069.final_assignments_qa)
UNION
(SELECT item_id,
        test_b   AS test_assignment,
       'test_b'  AS test_number,
        now()    AS test_start_date
FROM dsv1069.final_assignments_qa)
UNION
(SELECT item_id,
        test_c   AS test_assignment,
       'test_c'  AS test_number,
        now()    AS test_start_date
FROM dsv1069.final_assignments_qa)
UNION
(SELECT item_id,
        test_d   AS test_assignment,
       'test_d'  AS test_number,
        now()    AS test_start_date
FROM dsv1069.final_assignments_qa)
UNION
(SELECT item_id,
        test_e   AS test_assignment,
       'test_e'  AS test_number,
        now()    AS test_start_date
FROM dsv1069.final_assignments_qa)
UNION
(SELECT item_id,
        test_f   AS test_assignment,
       'test_f'  AS test_number,
        now()    AS test_start_date
FROM dsv1069.final_assignments_qa)
ORDER BY test_number ASC;
  





-- Use this table to 
-- compute order_binary for the 30 day window after the test_start_date
-- for the test named item_test_2

SELECT test_assignment,
       COUNT(DISTINCT item_id) AS number_of_items,
       SUM(order_binary) AS items_ordered_30d
FROM
    (SELECT item_id,
            test_assignment,
            MAX(CASE
                    WHEN (order_created_at > test_start_date AND DATE_PART('day', order_created_at - test_start_date) <= 30) THEN 1
                    ELSE 0 
                END) AS order_binary
   FROM
   
           (SELECT fa.item_id,
                   fa.test_assignment,
                   fa.test_number,
                   fa.test_start_date,
                   o.created_at AS order_created_at
            FROM dsv1069.final_assignments AS fa
            LEFT JOIN dsv1069.orders AS o
                  ON fa.item_id = o.item_id
            WHERE fa.test_number = 'item_test_2') AS item_test_2
      
   GROUP BY item_id,
            test_assignment,
            test_number,
            test_start_date,
            order_created_at) AS order_binary
          
GROUP BY test_assignment;





-- Use this table to 
-- compute view_binary for the 30 day window after the test_start_date
-- for the test named item_test_2

SELECT
test_assignment,
COUNT(item_id) AS items,
SUM(view_binary_30d) AS viewed_items,
SUM(views) AS views,
SUM(views)/COUNT(item_id) AS average_views_per_item
FROM 
(
 SELECT 
   fa.test_assignment,
   fa.item_id, 
   MAX(CASE WHEN view_items.event_time > fa.test_start_date THEN 1 ELSE 0 END)  AS view_binary_30d,
   COUNT(view_items.event_id) AS views
  FROM 
    dsv1069.final_assignments fa 
  LEFT OUTER JOIN 
    (
    SELECT 
      event_time,
      event_id,
      CAST(parameter_value AS INT) AS item_id
    FROM 
      dsv1069.events 
    WHERE 
      event_name = 'view_item'
    AND 
      parameter_name = 'item_id'
    ) view_items
  ON 
    fa.item_id = view_items.item_id
  AND 
    view_items.event_time >= fa.test_start_date
  AND 
    DATE_PART('day', view_items.event_time - fa.test_start_date ) <= 30
  WHERE 
    fa.test_number= 'item_test_2'
  GROUP BY
    fa.test_assignment,
    fa.item_id
) item_orders
GROUP BY 
 test_assignment;





 --Use the https://thumbtack.github.io/abba/demo/abba.html to compute the lifts in metrics and the p-values for the binary metrics ( 30 day order binary and 30 day view binary) using a interval 95% confidence. 

--Order binary:
-- p-value: 0.86	
-- improvement: 1%


--View binary:
-- p-value: 0.20	
-- improvement: 2.6%






--Order binary

---It can be said that the improvement value is 1% and the p_value is 0.86. This indicates that there is no significant difference in the number of orders within 30 days of the assigned treatment date between the two treatments.



--View Binary 

--It can be said that the improvement value is 2.6% and the p_value is 0.2. This indicates that there is no significant difference in the number of views within 30 days of the assigned treatment date between the two treated values.