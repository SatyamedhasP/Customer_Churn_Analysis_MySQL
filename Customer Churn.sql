-- Data Cleaning

-- 1. Find the total number of customers
SELECT DISTINCT COUNT(CustomerID) as TotalNumberOfCustomers
FROM ecommerce;
-- 4293 customers in the dataset

-- 2. Check for duplicate rows
SELECT CustomerID, COUNT(CustomerID) as Cnt
FROM ecommerce
GROUP BY CustomerID
HAVING COUNT(CustomerID) > 1;
-- No duplicate rows

-- 3. Check for null values count for columns with null values
SELECT 'Tenure' as ColumnName, COUNT(*) AS NullCount 
FROM ecommerce
WHERE Tenure IS NULL 
UNION
SELECT 'WarehouseToHome' as ColumnName, COUNT(*) AS NullCount 
FROM ecommerce
WHERE warehousetohome IS NULL 
UNION
SELECT 'HourSpendonApp' as ColumnName, COUNT(*) AS NullCount 
FROM ecommerce
WHERE hourspendonapp IS NULL
UNION
SELECT 'OrderAmountHikeFromLastYear' as ColumnName, COUNT(*) AS NullCount 
FROM ecommerce
WHERE orderamounthikefromlastyear IS NULL 
UNION
SELECT 'CouponUsed' as ColumnName, COUNT(*) AS NullCount 
FROM ecommerce
WHERE couponused IS NULL 
UNION
SELECT 'OrderCount' as ColumnName, COUNT(*) AS NullCount 
FROM ecommerce
WHERE ordercount IS NULL 
UNION
SELECT 'DaySinceLastOrder' as ColumnName, COUNT(*) AS NullCount 
FROM ecommerce
WHERE daysincelastorder IS NULL;
-- No null values

-- 4.Creating a column 'Customer Status' where 1 = Churned, 0 = Stayed from Churn column
ALTER TABLE ecommerce
DROP COLUMN CustomerStatus;

CREATE TABLE temp_table AS
SELECT *,
    CASE 
        WHEN Churn = 1 THEN 'Churned' 
        WHEN Churn = 0 THEN 'Stayed'
    END AS CustomerStatus
FROM ecommerce;

DROP TABLE ecommerce;
-- Column Customer Status created

-- 5. Create a new column 'ComplainReceived' based off the values of complain column.
-- In complain column 0=No and 1=Yes
CREATE TABLE temp_table AS
SELECT *,
    CASE 
        WHEN Complain = 1 THEN 'Yes' 
        WHEN Complain = 0 THEN 'No'
    END AS ComplainReceived
FROM ecommerce;

DROP TABLE ecommerce;

ALTER TABLE temp_table RENAME TO ecommerce;
-- Column Complain Received created

-- 6. Check values in each column for correctness and accuracy

-- 6.1 a) Check distinct values for preferredlogindevice column
SELECT DISTINCT preferredlogindevice 
FROM ecommerce;

-- 6.1 b) Replace mobile phone with phone
UPDATE ecommerce
SET preferredlogindevice = 'phone'
WHERE preferredlogindevice = 'mobile phone';

-- 6.2 a) Check distinct values for preferedordercat column
SELECT DISTINCT preferedordercat 
FROM ecommerce;

-- 6.2 b) Replace mobile with mobile phone
UPDATE ecommerce
SET preferedordercat = 'Mobile Phone'
WHERE Preferedordercat = 'Mobile';

-- 6.3 a) Check distinct values for preferredpaymentmode column
SELECT DISTINCT PreferredPaymentMode 
FROM ecommerce;

-- 6.3 b) Replace COD with Cash on Delivery
UPDATE ecommerce
SET PreferredPaymentMode  = 'Cash on Delivery'
WHERE PreferredPaymentMode  = 'COD';

-- 6.4 a) check distinct value in warehousetohome column
SELECT DISTINCT warehousetohome
FROM ecommerce;

-- 6.4 b) Replace value 127 with 27
UPDATE ecommerce
SET warehousetohome = '27'
WHERE warehousetohome = '127';

-- 6.4 C) Replace value 126 with 26
UPDATE ecommerce
SET warehousetohome = '26'
WHERE warehousetohome = '126';

-- Data Exploration

-- 1. What is the overall customer churn rate?
SELECT TotalCustomers, TotalChurnedCustomers, ROUND((TotalChurnedCustomers/TotalCustomers)*100,2) AS ChurnRate
FROM
(SELECT COUNT(*) AS TotalCustomers
FROM ecommerce) AS Total,
(SELECT COUNT(*) AS TotalChurnedCustomers
FROM ecommerce
WHERE CustomerStatus = 'Churned') AS Churned;

-- Churn Rate = 17.94%

-- 2. Churn Rate based on preferred login device
SELECT preferredlogindevice, COUNT(*) AS TotalCustomers, SUM(churn) AS ChurnedCustomers, ROUND((SUM(churn)/ COUNT(*))*100,2) AS ChurnRate
FROM ecommerce
GROUP BY preferredlogindevice
ORDER BY ChurnRate DESC;

-- Computer has a churn rate of 20.66% being the highest and phone has a churn rate of 16.79%

-- 3. Distribution of customers across different city tiers
SELECT citytier, 
       COUNT(*) AS TotalCustomer, 
       SUM(Churn) AS ChurnedCustomers, 
       ROUND((SUM(churn)/ COUNT(*))*100,2) AS ChurnRate
FROM ecommerce
GROUP BY citytier
ORDER BY churnrate DESC;
-- City tier 3 has the highest churn rate of 22.39% followed by city tier 2 (21.74%)and city tier 1 (15.49)

-- 4. Is there any correlation between the warehouse-to-home distance and customer churn?
ALTER TABLE ecommerce
ADD warehousetohomerange NVARCHAR(50);

UPDATE ecommerce
SET warehousetohomerange =
CASE 
    WHEN warehousetohome <= 10 THEN 'Very close distance'
    WHEN warehousetohome > 10 AND warehousetohome <= 20 THEN 'Close distance'
    WHEN warehousetohome > 20 AND warehousetohome <= 30 THEN 'Moderate distance'
    WHEN warehousetohome > 30 THEN 'Far distance'
END;

-- Finding correlation between warehousetohome and churnrate
SELECT warehousetohomerange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       ROUND((SUM(churn)/ COUNT(*))*100,2) AS ChurnRate
FROM ecommerce
GROUP BY warehousetohomerange
ORDER BY Churnrate DESC;
-- The churn rate increases as the warehousetohome distance increases
-- Far distance = 24.21%, Moderate distance = 22.28%, Close distance=17.25%, Very close distance = 15.28%

-- 5. Which is the most prefered payment mode among churned customers?
SELECT preferredpaymentmode,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       ROUND((SUM(churn)/ COUNT(*))*100,2) AS ChurnRate
FROM ecommerce
GROUP BY preferredpaymentmode
ORDER BY Churnrate DESC;
-- The most prefered payment mode among churned customers is Cash on Delivery = 24.2%

-- 7. Is there any difference in churn rate between male and female customers?
SELECT gender,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       ROUND((SUM(churn)/ COUNT(*))*100,2) AS ChurnRate
FROM ecommerce
GROUP BY gender
ORDER BY Churnrate DESC;
-- More men churned in comaprison to wowen , Male = 18.51% , Female = 17.05%

-- 8. How does the average time spent on the app differ for churned and non-churned customers?
SELECT customerstatus, avg(hourspendonapp) AS AverageHourSpentonApp
FROM ecommerce
GROUP BY customerstatus;
-- No difference

-- 9. Does the number of registered devices impact the likelihood of churn?
SELECT NumberofDeviceRegistered,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       ROUND((SUM(churn)/ COUNT(*))*100,2) AS ChurnRate
FROM ecommerce
GROUP BY NumberofDeviceRegistered
ORDER BY Churnrate DESC;
-- As the number of registered devices increseas the churn rate increases. 

-- 10. Which order category is most prefered among churned customers?
SELECT preferedordercat,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       ROUND((SUM(churn)/ COUNT(*))*100,2) AS ChurnRate
FROM ecommerce
GROUP BY preferedordercat
ORDER BY Churnrate DESC;
-- Mobile phone  has the highest churn rate and grocery has the least churn rate

-- 11. Is there any relationship between customer satisfaction scores and churn?
SELECT satisfactionscore,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       ROUND((SUM(churn)/ COUNT(*))*100,2) AS ChurnRate
FROM ecommerce
GROUP BY satisfactionscore
ORDER BY Churnrate DESC;
-- Customer satisfaction score of 5 has the highest churn rate, satisfaction score of 1 has the least churn rate

-- 12. Does the marital status of customers influence churn behavior?
SELECT maritalstatus,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       ROUND((SUM(churn)/ COUNT(*))*100,2) AS ChurnRate
FROM ecommerce
GROUP BY maritalstatus
ORDER BY Churnrate DESC;
-- Single customers have the highest churn rate while married customers have the least churn rate


-- 13. How many addresses do churned customers have on average?
SELECT AVG(numberofaddress) AS Averagenumofchurnedcustomeraddress
FROM ecommerce
WHERE customerstatus = 'churned';
-- Answer = On average, churned customers have 4 addresses

-- 14. Does customer complaints influence churned behavior?
SELECT ComplainReceived,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       ROUND((SUM(churn)/ COUNT(*))*100,2) AS ChurnRate
FROM ecommerce
GROUP BY ComplainReceived
ORDER BY Churnrate DESC;
-- Customers with complains had the highest churn rate = 33.58%

-- 15. How does the usage of coupons differ between churned and non-churned customers?
SELECT customerstatus, SUM(couponused) AS Sum_of_Coupon_Used
FROM ecommerce
GROUP BY customerstatus;
-- Churned customers used less coupons in comparison to non churned customers

-- 16. What is the average number of days since the last order for churned customers?
SELECT AVG(daysincelastorder) AS Average_Num_of_Days_Since_Last_Order
FROM ecommerce
WHERE customerstatus = 'churned';
-- The average number of days since last order for churned customer is 3

-- 17. Is there any correlation between cashback amount and churn rate?
-- Firstly, we will create a new column that provides a tenure range based on the values in tenure column
ALTER TABLE ecommerce
ADD cashbackamountrange NVARCHAR(50);

UPDATE ecommerce
SET cashbackamountrange =
CASE 
    WHEN cashbackamount <= 100 THEN 'Low Cashback Amount'
    WHEN cashbackamount > 100 AND cashbackamount <= 200 THEN 'Moderate Cashback Amount'
    WHEN cashbackamount > 200 AND cashbackamount <= 300 THEN 'High Cashback Amount'
    WHEN cashbackamount > 300 THEN 'Very High Cashback Amount'
END;

-- Finding correlation between cashbackamountrange and churned rate
SELECT cashbackamountrange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       ROUND((SUM(churn)/ COUNT(*))*100,2) AS ChurnRate
FROM ecommerce
GROUP BY cashbackamountrange
ORDER BY Churnrate DESC;
-- Customers with a Moderate Cashback Amount (Between 100 and 200) have the highest churn rate, followed by
-- High cashback amount, then very high cashback amount and finally low cashback amount













