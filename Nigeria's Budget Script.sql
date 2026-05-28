create table National_budget_categories(
NO int,
CODE int,
FUND text,
TOTAL_ALLOCATION numeric
);
-- previewing the data
select * from National_budget_categories;

-- creating the second table
create table Ministry_sector_allocation(
NO int,
CODE int,
MDA text,
SECTOR text,
PERSONNEL numeric,
OVERHEAD numeric,
CAPITAL numeric,
TOTAL_ALLOCATION numeric
);
-- previewing the data
select * from ministry_sector_allocation;

-- data cleaning
-- standardizing the  ministry_sector_allocation;
update  ministry_sector_allocation
set 
mda = trim(lower(mda)),
sector = trim(lower(sector));

-- standardizing the national budget table
update  National_budget_categories
set 
fund= trim(lower(fund));

-- checking for null values
select
count(*) filter (where no is null) as missing_no,
count(*) filter (where code is null) as missing_code,
count(*) filter (where fund is null) as missing_fund,
count(*) filter (where  total_allocation is null) as missing_total_allocation
from National_budget_categories; -- no missing values

select
distinct sector
from ministry_sector_allocation; -- this data analyses 19 sectors

-- null values andduplicates have been removed during extraction process

-- calculating revenue_spending  
-- this is to determine how much goes into running government operations
select
sector,
sum(personnel + overhead) as recurrent_spending 
from
ministry_sector_allocation
group by sector
order by recurrent_spending desc; 
-- economics managment is the sector spending more on government operations 
-- agriculture & environment is the least

-- to see the percentage spent on govermnet operations
select
sector,
round( 
100.0 *sum( personnel + overhead )/ sum(total_allocation),
2) as recurrent_rate
from
ministry_sector_allocation
group by sector
order by recurrent_rate desc;
--governance & administration spends the most
--infrastructure & technology spends the least ongovernment operations

-- how are each sector focused on development
select
sector,
round( 
100 *sum( capital )/ sum(total_allocation),
2) as capital_rate
from
ministry_sector_allocation
group by sector
order by capital_rate desc; -- transport has the highest capital rate
--the 2026 budgetbudget ismore invested into transportation and energy
-- this should raise the question, why is fuel cost still high,

-- what sector has the hihest share in the budget of 2026

select
sector,
round( 
100 *sum( total_allocation )/ sum( sum( total_allocation)) 
over (), 2)
 as sector_share_percentage
from
ministry_sector_allocation
group by sector
order by sector_share_percentage desc;
-- economic managent got more than half of the budget and gives 75% to government operations

-- =========================================================
-- Research question 1
--==========================================================

-- How is Nigeria’s 2026 federal budget distributed across major national obligations and development priorities?
select
fund,
round(sum(total_allocation), 2) as allocation,
round(100 * sum(total_allocation)/ 
sum(sum(total_allocation)) over (), 2) as allocation_percentage
from National_budget_categories
group by fund
order by allocation desc;
-- 30.84% of the national budget is going into paying the nation's debt

-- which section of funds is priority to the nation now
select
fund,
round(sum(total_allocation), 2) as allocation
from National_budget_categories
where fund in ('debt services', 'crf charges-capitalsupplementation', 'capital development fund main')
group by fund
order by allocation desc; --paying of debt is of upmost priority

-- ====================================
-- Researcg question 2
-- ====================================

-- how much of nigerians budget allocated to operations vs long term development
-- total recurrent_spending vs capital_spending
select
sector,
round(sum(personnel + overhead), 2) as recurrent_spending,
round(sum( capital ), 2) as capial_spending,
round( 
100 *sum( personnel + overhead )/ sum(total_allocation),
2) as recurrent_rate,
round( 
100 *sum( capital )/ sum(total_allocation),2) as capital_rate
from ministry_sector_allocation
group by sector
order by recurrent_rate, capital_rate desc; -- the long term developmet is tilted toward transportstion ad infrastructure

-- ==============================
-- research question 3
-- ==============================
-- how is nigerian's 2026 budget distributed across key citizen-facing sector such as educational, health...
-- 3A citizen sector allocation

select sector, 
round(sum(total_allocation), 2)as allocation
from ministry_sector_allocation
where sector in ('education','health & social welfare','agriculture & environment','infrastructure & transport')
group by sector
order by allocation desc; -- transport is more, education.health..then agriculture

-- 3B waht is the citizen-sector share of total national budget?
select
sector,
round(sum(total_allocation), 2) as allocation ,
round(100 * sum(total_allocation) / sum(sum(total_allocation)) over (),2 ) as percentage_share
from ministry_sector_allocation
where sector in ('education','health & social welfare','agriculture & environment','infrastructure & transport')
group by sector
order by allocation;

-- 3c
SELECT
    'education' AS category,
    ROUND(SUM(total_allocation), 2) AS allocation
FROM ministry_sector_allocation
WHERE sector = 'education'
UNION ALL
SELECT
    'Health',
    ROUND(SUM(total_allocation), 2)
FROM ministry_sector_allocation
WHERE sector = 'health & social welfare'
UNION ALL
SELECT
    'agriculture & environment',
    ROUND(SUM(total_allocation), 2)
FROM ministry_sector_allocation
WHERE sector = 'agriculture & environment'
UNION ALL
SELECT
    'infrastructure & transport',
    ROUND(SUM(total_allocation), 2)
FROM ministry_sector_allocation
WHERE sector = 'infrastructure & transport';

-- ========================================
-- Reasearch question 4
-- Which sectors and MDAs are most administrative-heavy based on the proportion of personnel and overhead costs?
-- =========================================

SELECT
 sector,
 ROUND(SUM(personnel + overhead), 2) AS adminstrative_cost,
    ROUND(SUM(total_allocation), 2) AS total_budget,
    ROUND(
        100.0 * SUM(personnel + overhead)
        / SUM(total_allocation),
    2) AS admin_ratio
FROM ministry_sector_allocation
GROUP BY sector
ORDER BY admin_ratio DESC; -- the total budget are way more than the administrative cost, since these cost are fixed

-- top MDA by administrative
SELECT
 sector,
 ROUND(SUM(personnel + overhead), 2) AS adminstrative_cost,
    ROUND(SUM(total_allocation), 2) AS total_budget,
    ROUND(
        100.0 * SUM(personnel + overhead)
        / SUM(total_allocation),
    2) AS admin_ratio
FROM ministry_sector_allocation
GROUP BY sector
ORDER BY admin_ratio DESC
limit 10;

-- highest personnel cost sector
select
sector,
round(sum(personnel), 2) as personnel_cost
from ministry_sector_allocation
group by sector
order by personnel_cost desc; -- security and governance has the most personnel cost
-- with sport as the least personnel cost

-- ==============================================
-- research question 5
-- ==============================================

-- what do  nigerian budget allocation pattern reveal about broader fiscaland development priorities
-- =============================================
-- top 10 mda's by allocation
select mda,
round(sum(total_allocation), 2) as allocation
from ministry_sector_allocation
group by mda
order by allocation  desc
limit 10; --the federal ministries has the top 10 allocatio...
-- with ministry of finance toppig the list

--what sector is allocation more concentrated in?


