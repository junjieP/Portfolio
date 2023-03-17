use Projects;

create table customer_shopping_data (
	invoice_no varchar(255) primary key,
	customer_id varchar(255) not null,
    gender varchar(255) not null,
    age int not null,
    category varchar(255) not null,
    quantity int not null,
    price double not null,
    payment_method varchar(255) not null,
	invoice_date varchar(255) not null,
    shopping_mall varchar(255) not null
);

LOAD DATA INFILE 'C:/file/projects/Customer Shopping Dataset/customer_shopping_data.csv' INTO TABLE customer_shopping_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

-- Convert invoice_date from str to datetime format
select invoice_no, customer_id, category, quantity, price, 
	   str_to_date(invoice_date, '%d/%m/%Y') as invoice_date,
       shopping_mall 
from customer_shopping_data;

-- Check if any cutomer have mutiple records
select customer_id, count(customer_id) from customer_shopping_data
group by customer_id
having count(customer_id) > 1; 

-- Top 5 customers in 2022 and their preferance
create table Top_5_customer_2022 as
select customer_id, group_concat(distinct category) as categories,
	   sum(quantity) as total_quantity,
	   round(sum(price),2) as total_price,
       group_concat(distinct shopping_mall) as favourite_malls
from customer_shopping_data
where str_to_date(invoice_date, '%d/%m/%Y') between '2022-01-01' and '2022-12-31'
group by customer_id
order by total_price desc
limit 5;

-- Percentage of sales per market in 2022
create table market_percentage_2022 as
select shopping_mall, sum(quantity) as total_quantity,
	   round(sum(price),2) as total_sales,
       round(sum(price)/(select sum(price) from customer_shopping_data
						where str_to_date(invoice_date, '%d/%m/%Y')
						between '2022-01-01' and '2022-12-31')*100, 2) as percentage
from customer_shopping_data
where str_to_date(invoice_date, '%d/%m/%Y') between '2022-01-01' and '2022-12-31'
group by shopping_mall
order by sum(price) desc;

-- Total sales of each category in different markets in 2022
create table sales_of_each_category_2022 as
select distinct shopping_mall, category,
	   (sum(quantity) over(partition by category, shopping_mall)) as total_quantity,
	   round((sum(price) over(partition by category, shopping_mall)), 2) as total_sales
from customer_shopping_data
where str_to_date(invoice_date, '%d/%m/%Y') between '2022-01-01' and '2022-12-31'
order by shopping_mall asc, total_sales desc;
