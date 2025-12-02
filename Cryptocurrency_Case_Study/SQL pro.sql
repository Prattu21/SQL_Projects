#LAB1
select count(*) from transactions;
#Q1
select * from members
limit 5;

#Q2
select * from members
order by first_name
limit 3;

#Q3 Count the number of records from the members table which have United States as the region value?
select count(*) from members 
where region = 'United States';

#Q4 Select only the first_name and region columns for mentors who are not from Australia?
select first_name,region from members
where region <> 'Australia';

#Q5 Return only the unique region values from the members table and sort the output by reverse alphabetical order?
select distinct region from members
order by region desc;
-----------------------------------------------------------------------------------------------------------------------------------------------
#LAB2
#Q1 How many records are there per ticker value in the prices table?
select ticker,count(*) from prices
group by ticker;

#Q2 What is the maximum, minimum values for the price column for both Bitcoin and Ethereum in 2020?
select ticker,max(price),min(price) from prices
where market_date between '2020-01-01' and '2020-12-31'
group by ticker;
select count(*) from prices;

desc prices;
alter table prices add  market_date_new date;
update prices set market_date_new =str_to_date(market_date,'%d-%m-%Y'); 
ALTER TABLE prices DROP COLUMN market_date;
ALTER TABLE prices CHANGE market_date_new market_date DATE;

alter table prices add  volume_new int;
update prices set volume_new =(case
when right(volume,1)='K'then left(volume,length(volume)-1)*1000
when right(volume,1)='M' then left(volume,length(volume)-1)*1000000
end ) ;
ALTER TABLE prices DROP COLUMN volume;
ALTER TABLE prices CHANGE volume_new volume int;
select * from prices;

#Q3 What is the annual minimum, maximum and average price for each ticker?
select year(market_date),ticker,min(price),max(price),round(avg(price),1) from prices
group by year(market_date),ticker
order by year(market_date),ticker;

#Q4 What is the monthly average of the price column for each ticker from January 2020 and after?
select year(market_date),month(market_date),round(avg(price),1) from prices
where market_date > '2020-01-01'
group by ticker,year(market_date),month(market_date)
order by ticker,year(market_date),month(market_date);
-------------------------------------------------------------------------------------------------------------------------------------------------
#lab 3
# Q1 Convert the volume column in the prices table with an adjusted integer value to take into the unit values
#Return only the market_date, price, volume and adjusted_volume columns for the first 10 days of August 2021 for Ethereum only
select market_date, price, volume,
case
when right(volume,1)='K'then left(volume,length(volume)-1)*1000
when right(volume,1)='M' then left(volume,length(volume)-1)*1000000
end as adjusted_volume
from prices
where ticker='Eth' and market_date >='2021-08-01'
order by market_date
limit 10;

#Q2 How many "breakout" days were there in 2020 where the price column is greater than the open column for each ticker? 
#In the same query also calculate the number of "non breakout" days where the price column was lower than or equal to the open column. 
select ticker,sum(price>open) as breakout,sum(price<open) as nonbreakout from prices
where year(market_date)='2020'
group by ticker;

#Q3 What was the final quantity Bitcoin and Ethereum held by all Data With Danny mentors based off the transactions table?
select * from prices;
select * from transactions;

select t.ticker,sum(case when txn_type='buy' then +quantity else -quantity end) as final_quantity from transactions t 
join members m on t.member_id=m.member_id
where m.first_name="Danny"
group by t.ticker;

-------------------------------------------------------------------------------------------------------------------------------------------------
#lab 4
#Q1:- What are the market_date, price and volume and price_rank values for the days with the top 5 highest price values for each tickers in the prices table?
#a)The price_rank column is the ranking for price values for each ticker with rank = 1 for the highest value.
#b)Return the output for Bitcoin, followed by Ethereum in price rank order.
select ticker,market_date,price,volume,
rank() over(partition by ticker order by price desc)as t from prices as m
where t <= 5;

#Q2 Calculate a 7 day rolling average for the price and volume columns in the prices table for each ticker.
#a)Return only the first 10 days of August 2021
select ticker,market_date,
AVG(price) OVER (
        PARTITION BY ticker
        ORDER BY market_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS avg_price_7d,
    AVG(volume) OVER (
        PARTITION BY ticker
        ORDER BY market_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS avg_volume_7d 
    from prices
    where market_date between '2021-08-01' and '2021-08-10'
    order by ticker,market_date;
    


#Question 4:- Calculate the daily percentage change in volume for each ticker in the prices table?
#a)Percentage change can be calculated as (current - previous) / previous
#b)Multiply the percentage by 100 and round the value to 2 decimal places
#c)Return data for the first 10 days of August 2021
select ticker,market_date,volume,
LAG(volume) OVER (PARTITION BY ticker ORDER BY market_date
) AS prev_volume,
round(((volume - LAG(volume) OVER (PARTITION BY ticker ORDER BY market_date))/
LAG(volume) OVER (PARTITION BY ticker ORDER BY market_date)*100),2)
as percentage_change
from prices
where market_date>'2021-08-01'
order by ticker,market_date
limit 10;
------------------------------------------------------------------------------------------------------------------------------------------------
#lab5 
#Question 1 - Which top 3 mentors have the most Bitcoin quantity? 
#Return the first_name of the mentors and sort the output from highest to lowest total_quantity?
select m.first_name,
sum(case when t.txn_type='buy' then +t.quantity else -t.quantity end) as total_quant from members m
join transactions t on m.member_id=t.member_id
where t.ticker='BTC'
group by m.first_name
order by total_quant desc limit 3;

#Question 2 - Show the market_date values which have less than 5 transactions?
# Sort the output in reverse chronological order.
alter table transactions add  txn_date_new date;
update transactions set txn_date_new =str_to_date(txn_date,'%d-%m-%Y'); 
ALTER TABLE transactions DROP COLUMN txn_date;
ALTER TABLE transactions CHANGE txn_date_new txn_date DATE;
desc transactions;

#OR
set sql_safe_updates=0;
update transactions set txn_date = str_to_date(txn_date,'%d-%m-%Y');
alter table transactions modify txn_date date;

select p.market_date,count(t.txn_id) 
from prices p
left join transactions t on t.ticker = p.ticker AND t.txn_date = p.market_date
group by p.market_date
having count(t.txn_id) < 5
order by p.market_date desc;

#Q3 
with cte as(
select 
date_format(txn_date,'%Y-01-01') as start_year,region,sum(quantity*price)/sum(quantity) as btc_dca from transactions t
join members m on t.member_id=m.member_id 
join prices p on t.ticker=p.ticker and t.txn_date=p.market_date
group by date_format(txn_date,'%Y-01-01'),region )
select 
start_year,region ,btc_dca,
rank() over(partition by start_year order by btc_dca asc)
as dca_ranking,
round((btc_dca-lag(btc_dca) over(partition by region order by start_year))/
lag(btc_dca) over (partition by region order by start_year)*100,2) as dca_prc_change  from cte;


