use ecomm;
-- data cleaning
UPDATE CUSTOMER_CHURN
SET WarehouseToHome = (
    SELECT avg_value
    FROM (SELECT ROUND(AVG(WarehouseToHome)) AS avg_value
        FROM CUSTOMER_CHURN
    ) AS temp
)
WHERE WarehouseToHome IS NULL;

UPDATE CUSTOMER_CHURN
SET HoursSpentOnApp = (
    SELECT avg_value
    FROM (
        SELECT ROUND(AVG(HoursSpentOnApp)) AS avg_value
        FROM CUSTOMER_CHURN
    ) AS temp
)
WHERE HoursSpentOnApp IS NULL;

UPDATE CUSTOMER_CHURN
SET OrderAmountHikeFromlastYear = (
    SELECT avg_value
    FROM (
        SELECT ROUND(AVG(OrderAmountHikeFromlastYear)) AS avg_value
        FROM CUSTOMER_CHURN
    ) AS temp
)
WHERE OrderAmountHikeFromlastYear IS NULL;

UPDATE CUSTOMER_CHURN
SET DaySinceLastOrder = (
    SELECT avg_value
    FROM (
        SELECT ROUND(AVG(DaySinceLastOrder)) AS avg_value
        FROM CUSTOMER_CHURN
    ) AS temp
)
WHERE DaySinceLastOrder IS NULL;


DELETE FROM customer_churn
WHERE WarehouseToHome > 100;





-- dealing with inconsistency
update customer_churn
set PreferredLoginDevice = "mobile phone"
where PreferredLoginDevice = "phone";

update customer_churn
set PreferedOrderCat = "mobile phone"
where PreferedOrderCat = "mobile";

update customer_churn
set preferredpaymentmode = "credit card"
where preferredpaymentmode = "CC";

update customer_churn
set preferredpaymentmode = "cash on delivery"
where preferredpaymentmode = "COD";

-- data transformation
alter table customer_churn
rename column PreferedOrderCat to PreferredOrderCat;

alter table customer_churn
rename column HourSpendOnApp to HoursSpentOnApp;

alter table customer_churn
add column ComplaintReceived varchar(5);

UPDATE customer_churn
SET ComplaintReceived = CASE
        WHEN Complain = 1 THEN 'Yes'
        ELSE 'No'
    END;
    
alter table customer_churn
add column ChurnStatus varchar(10);

UPDATE customer_churn
SET ChurnStatus = CASE
        WHEN Churn = 1 THEN 'Churned'
        ELSE 'Active'
    END;
    
 ALTER TABLE CUSTOMER_CHURN
DROP COLUMN Churn,
DROP COLUMN Complain; 

SELECT * FROM customer_churn;  

-- Data Exploration and Analysis
select churnstatus,
count(*) as customercount
from customer_churn
group by churnstatus;

select AVG(Tenure) AS AverageTenure,
    SUM(CashbackAmount) AS TotalCashback
FROM customer_churn
WHERE ChurnStatus = 'Churned';

use ecomm;
select citytier,
count(*) as customercount
from customer_churn
where churnstatus = 'churned'
and preferredordercat = 'Laptop & Accessory'
GROUP BY CityTier
ORDER BY CustomerCount DESC
LIMIT 1;

select PreferredPaymentMode,
    COUNT(*) AS CustomerCount
from customer_churn
where ChurnStatus = 'Active'
group by PreferredPaymentMode
order by CustomerCount DESC;


select
    SUM(OrderAmountHikeFromlastYear) AS TotalOrderAmountHike
from customer_churn
where MaritalStatus = 'Single'
  and PreferredOrderCat = 'Mobile Phone';
  
select
    avg(NumberOfDeviceRegistered) AS AverageDevicesRegistered
FROM customer_churn
WHERE PreferredPaymentMode = 'UPI';

select
    CityTier,
    COUNT(*) AS CustomerCount
from customer_churn
group by CityTier
order by CustomerCount DESC;


SELECT
    Gender,
    SUM(CouponUsed) AS TotalCouponsUsed
FROM customer_churn
GROUP BY Gender
ORDER BY TotalCouponsUsed DESC;

select
    PreferredOrderCat,
    COUNT(*) AS CustomerCount,
    MAX(HoursSpentOnApp) AS MaximumHoursSpent
from customer_churn
group by PreferredOrderCat;

select
    SUM(OrderCount) AS TotalOrderCount
from customer_churn
WHERE PreferredPaymentMode = 'Credit Card'
  AND SatisfactionScore = 
      (SELECT MAX(SatisfactionScore)
      FROM customer_churn);
      
select
    avg(SatisfactionScore) as AverageSatisfactionScore
from  customer_churn
where ComplaintReceived = 'Yes';

select distinct PreferredOrderCat
FROM customer_churn
WHERE CouponUsed > 5;

use ecomm;
select
    PreferredOrderCat,
    AVG(CashbackAmount) AS AverageCashback
from customer_churn
group by PreferredOrderCat
order by AverageCashback DESC;

select distinct PreferredPaymentMode
from customer_churn
where OrderCount > 500
  and Tenure = 10;
  
  select case
        when WarehouseToHome <= 5
            then 'Very Close Distance'
       when WarehouseToHome <= 10
            then 'Close Distance'
        when WarehouseToHome <= 15
            then 'Moderate Distance'
       else 'Far Distance'
    end as DistanceCategory,
    ChurnStatus,
    COUNT(*) AS CustomerCount
from customer_churn
group by DistanceCategory, ChurnStatus
order by DistanceCategory, ChurnStatus;

select *
from customer_churn
where MaritalStatus = 'Married'
  and CityTier = 1
 and OrderCount > (
      select avg(OrderCount)
     from customer_churn
  );
  
  create table customer_returns(
    return_id int primary key,
    customer_id int,
    returndate date,
    refundamount int);
    
    insert into customer_returns
    (return_id,customer_id,returndate,refundamount)
VALUES
    (1001, 50022, '2023-01-01', 2130),
    (1002, 50316, '2023-01-23', 2000),
    (1003, 51099, '2023-02-14', 2290),
    (1004, 52321, '2023-03-08', 2510),
    (1005, 52928, '2023-03-20', 3000),
    (1006, 53749, '2023-04-17', 1740),
    (1007, 54206, '2023-04-21', 3250),
    (1008, 54838, '2023-04-30', 1990);
    
    select *from customer_returns;
    
  select
    c.Return_ID,
    c.Customer_ID,
    c.ReturnDate,
    c.RefundAmount,
    e.*
from customer_returns as c
inner join customer_churn as e
   on c.Customer_ID = c.Customer_ID
where e.ChurnStatus = 'Churned'
  and e.ComplaintReceived = 'Yes';
    
      
      



      