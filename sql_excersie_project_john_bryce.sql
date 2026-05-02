--question 1
with monthly_incom as (
    select  year(i.InvoiceDate) as InvoiceYear, month(i.invoiceDate) as InvoiceMonth,
        sum(inl.ExtendedPrice-inl.TaxAmount) as IncomPerMonth
    from Sales.Invoices i 
    join Sales.InvoiceLines inl 
    on i.InvoiceID=inl.InvoiceID
    group by year(i.InvoiceDate),month(i.invoiceDate)
), yearly_stats 
as (
    select  
        InvoiceYear,
        sum(IncomPerMonth) as IncomePerYear,
        count(distinct(mi.IncomPerMonth)) as NumberOfDistinctMonth,
        avg(mi.IncomPerMonth)*12 as YearlyLinearIncom
    from monthly_incom mi
    group by InvoiceYear
)
select
 ys.InvoiceYear, 
 format(ys.IncomePerYear, 'N2') as IncomePerYear,
 ys.NumberOfDistinctMonth,
 format(ys.YearlyLinearIncom, 'N2') as YearlyLinearIncom,
 cast(round((ys.YearlyLinearIncom -lag(ys.YearlyLinearIncom) over(order by ys.InvoiceYear ))/lag(ys.YearlyLinearIncom) over(order by ys.YearlyLinearIncom )*100,2) as float) as GrowthRate
from yearly_stats ys
order by ys.InvoiceYear

go 

--question 2
with income_per_customer as (
select 
    year(i.InvoiceDate) as TheYear,
    datepart(quarter, i.InvoiceDate) as TheQuarter,
    c.CustomerName,
    sum(inl.ExtendedPrice-inl.TaxAmount) as IncomePerQuarterYear
from Sales.InvoiceLines inl  
join Sales.Invoices i
    on i.InvoiceID=inl.InvoiceID
join Sales.Customers c 
    on i.CustomerID = c.CustomerID
group by  year(i.InvoiceDate), datepart(quarter, i.InvoiceDate),c.CustomerName
), ranking_by_quarter_year as (
select *,
 dense_rank() over(partition by TheYear,TheQuarter order by IncomePerQuarterYear desc) as DNR
from income_per_customer
)
select * 
from ranking_by_quarter_year
where DNR between 1 and 5 

go 

--question 3
select Top 10
    inl.StockItemID, 
    inl.Description as StockItemName, 
    sum(inl.ExtendedPrice-inl.TaxAmount) as TotalProfit
from Sales.InvoiceLines inl
group by inl.StockItemID, inl.Description
order by TotalProfit desc 

go 

--question 4
with items_nominal_profit as (
select 
    si.StockItemID, 
    si.StockItemName, 
    si.UnitPrice, 
    si.RecommendedRetailPrice,
    (si.RecommendedRetailPrice-si.UnitPrice) as NominalProductProfit
from Warehouse.StockItems si 
where si.ValidTo > CURRENT_TIMESTAMP
)
select 
    ROW_NUMBER() over(order by NominalProductProfit desc) as Rn
    ,* ,
    dense_rank() over(order by NominalProductProfit desc) as DNR
from items_nominal_profit

go 

--question 5
with items_by_suppliers as (
select 
    s.SupplierID,
    concat(s.SupplierID,' - ',s.SupplierName) as SupplierDetails,
   concat(si.StockItemID,' ',si.StockItemName) product
from Purchasing.Suppliers s 
join Warehouse.StockItems si 
    on s.SupplierID = si.SupplierID
)
select 
    ibs.SupplierDetails,
    string_agg(ibs.product, '/, ') as ProductDetails
from items_by_suppliers ibs
group by ibs.SupplierDetails, ibs.SupplierID
order by ibs.SupplierID

go 

--question 6
with customer_location as (
select 
    cu.CustomerID,
    c.CityName,
    con.CountryName,
    con.Continent,
    con.Region
from Sales.Customers cu 
join Application.Cities c 
    on cu.PostalCityID = c.CityID
join Application.StateProvinces sp
    on sp.StateProvinceID = c.StateProvinceID
join Application.Countries con 
    on sp.CountryID = con.CountryID
), customer_total as (
select 
    i.CustomerID, 
    sum(inl.ExtendedPrice) as TotalExtendedPrice
from Sales.Invoices i 
join Sales.InvoiceLines inl 
    on i.InvoiceID = inl.InvoiceID
group by i.CustomerID
)
select top 5 
    cl.*,
    format (ct.TotalExtendedPrice, 'N2') as TotalExtendedPrice
from customer_location cl
join customer_total ct 
    on cl.CustomerID = ct.CustomerID
order by ct.TotalExtendedPrice desc

go 

--question 7
with total_per_month as (
select 
    year(i.invoiceDate) as InvoiceYear, 
    month(i.InvoiceDate) as InvoiceMonth,
    sum(inl.ExtendedPrice-inl.TaxAmount)  as MonthlyTotal
from Sales.Invoices i 
join Sales.InvoiceLines inl 
    on i.InvoiceID = inl.InvoiceID
group by  grouping sets (year(i.InvoiceDate),(year(i.invoiceDate),month(i.InvoiceDate)))
)
select 
    tpm.InvoiceYear,
    case 
        when tpm.InvoiceMonth is null then 'Grand Total'
        else cast(tpm.InvoiceMonth as varchar(3))
    end as InvoiceMonth,
    format(tpm.MonthlyTotal, 'N2') as MonthlyTotal,
    case 
        when tpm.InvoiceMonth is null then format(tpm.MonthlyTotal,'N2')
        else format(sum(tpm.MonthlyTotal) over(partition by tpm.InvoiceYear order by case when tpm.InvoiceMonth is null then 999 else tpm.InvoiceMonth end rows between unbounded preceding and current row), 'N2')
    end as CumulativeTotal
from total_per_month tpm

go

--question 8
select * 
from 
(select year(o.OrderDate) as year, month(o.OrderDate) as OrderMonth, o.OrderID from Sales.Orders o ) t
pivot (count(t.OrderID) for year in ([2013],[2014],[2015],[2016])) as pvt 
order by OrderMonth

go 

--question 9
with max_order_date as (
select 
    max(o.OrderDate) as last_order_date 
from Sales.Orders o 
)
, previous_order_date as (
select 
    o.CustomerID,   
    o.OrderDate,
    lag(o.OrderDate) over(partition by CustomerID order by o.OrderDate) as previous_order_date,
    max(o.OrderDate) over(partition by CustomerID) as latest_order_date_customer
from Sales.Orders o
)
, averge_order_date as (
select 
    pov.CustomerID,
    avg(datediff(day, pov.previous_order_date,pov.OrderDate)) as average_days_between_orders
from previous_order_date pov 
group by pov.CustomerID
)
select 
    aod.CustomerID,
    c.CustomerName,
    pod.OrderDate,
    pod.previous_order_date as PreviousOrderDate,
    aod.average_days_between_orders as AverageDaysBetweenOrders,
    pod.latest_order_date_customer as LastCustOrderDate,
    max(pod.OrderDate) over() as LastOrderDateALL,
    datediff(day,pod.latest_order_date_customer,max(pod.OrderDate) over()) as DaysSinceLastOrder,
    case 
        when datediff(day,pod.latest_order_date_customer,(select last_order_date from max_order_date)) >= 2*aod.average_days_between_orders then 'Potential Churn'
        else 'Active'
    end as CustomerStatus
from averge_order_date aod
join previous_order_date pod
    on pod.CustomerID=aod.CustomerID
join Sales.Customers c 
    on c.CustomerID = aod.CustomerID

go 

--question 10
with customer_category as (
select distinct
    case 
        when c.CustomerName like '%Wingtip%' then 'customer_1'
        when c.CustomerName like '%Tailspin%' then 'customer_2'
        else c.CustomerName
    end as customer_name,
    cc.CustomerCategoryName
from Sales.Customers c 
join Sales.CustomerCategories cc
    on c.CustomerCategoryID=cc.CustomerCategoryID
), total_cust_count as (
select 
    cg.customer_name,
    cg.CustomerCategoryName,
    count(customer_name) over() as TotalCustCount
from customer_category cg 
), customers_per_categoy as (
select  
    tcc.CustomerCategoryName,
    count(tcc.customer_name) as CustomerCOUNT,
    tcc.TotalCustCount
from total_cust_count tcc
group by tcc.CustomerCategoryName, tcc.TotalCustCount
)
select 
    cpg.*,
    concat(cast(round((cpg.CustomerCOUNT*100.00/cpg.TotalCustCount),2) as decimal(10,2)), '%') as DistributionFactor
from customers_per_categoy cpg

-- The categories with the highest share of unique customers are Novelty Shop (22.43%) 
-- and Supermarket (22.05%). A high concentration of customers in these categories
-- suggests that the business is more dependent on them. Therefore, any negative 
-- change in behavior or demand from these groups would impact a larger portion 
-- of the customer base, indicating higher business risk for those categories.
