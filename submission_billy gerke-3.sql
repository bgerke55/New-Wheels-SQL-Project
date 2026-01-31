/*

-----------------------------------------------------------------------------------------------------------------------------------
													    Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------
Queries

-----------------------------------------------------------------------------------------------------------------------------------*/

/*-- QUESTIONS RELATED TO CUSTOMERS
[Q1] What is the distribution of customers across states?
Hint: For each state, count the number of customers.*/

select state,count(*) num_of_customers
from customer_t
group by state;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter. 

Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/

select case
	when customer_feedback = "very bad" then 1
	when customer_feedback = "bad" then 2
when customer_feedback = "okay" then 3
when customer_feedback = "good" then 4
when customer_feedback = "very good" then 5
end as Ratings, quarter_number
from order_t;

with ratings as (
select quarter_number, case
	when customer_feedback = "very bad" then 1
	when customer_feedback = "bad" then 2
when customer_feedback = "okay" then 3
when customer_feedback = "good" then 4
when customer_feedback = "very good" then 5
end as r
from order_t)
select quarter_number, avg(r) as avg_rating
from ratings
group by quarter_number;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.

Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/

with rating as (
select distinct customer_feedback, quarter_number,
count(*) over (partition by quarter_number) count_qtr,
count(*) over (partition by quarter_number, customer_feedback) count_qtr_feedback
from order_t)
select *, count_qtr_feedback/count_qtr*100 from rating;




-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/

select
	vehicle_maker,
count(quantity) vehicles_sold
from product_t left join order_t
	using(product_id)
group by vehicle_maker
order by vehicles_sold desc limit 5;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker.
After ranking, take the vehicle maker whose rank is 1.*/

select * from (
select state,vehicle_maker,count(*) as order_state,
rank() over (partition by state order by count(*) desc) as state_rank
from order_t inner join customer_t using (customer_id)
inner join product_t using (product_id)
group by 1,2) as statetbl
where state_rank = 1;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/

select
quarter_number,
count(order_id) as orders_by_qtr
from Order_t
group by quarter_number
order by orders_by_qtr desc;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue?

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.*/


with revenue as (
select quarter_number,
sum(vehicle_price*quantity*(1-discount/100)) as revenue,
lag(sum((vehicle_price*quantity*(1-discount/100))),1) over (order by quarter_number) as previous_rev
from order_t
group by quarter_number)
select *, ((revenue-previous_rev)/(previous_rev)*100) as rev_diff
from revenue;



-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/

select quarter_number,
sum(vehicle_price*quantity*(1-discount/100)) as revenue,
count(*) order_id
from order_t
group by quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING
[Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/

select
	credit_card_type,
avg(discount)
from order_t inner join customer_t using (customer_id)
group by credit_card_type;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/

select quarter_number, avg(datediff(ship_date,order_date)) as avg_time_qtr
from order_t
group by quarter_number;

-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



