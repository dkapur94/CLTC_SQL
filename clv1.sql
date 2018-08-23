%sql

select quart1,
       line_of_buss,
       trans,
       (gpm*trans) AS gp
from
(select *, CASE
                 WHEN line_of_buss = 'DF' THEN 420
                 WHEN line_of_buss = 'DH' THEN 1048
                 WHEN line_of_buss = 'IF' THEN 900
                 WHEN line_of_buss = 'IH' THEN 2599
                 ELSE NULL
             END AS gpm
from(
select quart1, line_of_buss,sum(trnx) as trans
from
(
select *
from
(
(select ceil((visit_month+1)/3) as quart1,email
from
(select email, (datediff(acq_dt,'2016-01-01') DIV 31) as visit_month
from(
select u1.e as email,acq_dt
from(
(select *
from
(
(select e,min(date) as acq_dt,lob
from hydra.txn_search
where date_part>='2016-01-01' and type = 'txn' 
and lob in ('dom htl',
            'intl htl',
            'dom flt',
            'int flt')
group by e,lob)a

inner join
(select e as em,device_type
from hydra.txn_search
where date_part>='2016-01-01' and type = 'txn' and lower(trim(device_type)) = 'desktop' 
and lob in ('dom htl',
            'intl htl',
            'dom flt',
            'int flt')
group by e,device_type)b
on(a.e=b.em))
)u1

inner join
(select e,bkg_id,date
from hydra.txn_search
where date_part >='2016-01-01' and type = 'txn' and lower(trim(device_type)) ='desktop'
group by e, bkg_id,date
order by e)u2

on (u1.e=u2.e)
)
group by email,acq_dt,lob)
group by email,visit_month)
order by ceil((visit_month+1)/3))q1
inner join 
(select e,ceil((visit_month+1)/3) as quart2,line_of_buss,trnx
from
(select e, line_of_buss,count(distinct bkg_id) as trnx , (datediff(date,'2016-01-01') DIV 31) as visit_month
from (select *,
case 
when lob ='dom flt' then 'DF' 
when lob = 'intl flt' then 'IF' 
when lob = 'dom htl' then 'DH' 
when lob = 'intl htl' then 'IH' 
else null 
end as line_of_buss
from hydra.txn_search dfg
where dfg.e in 
(select distinct e 
from hydra.txn_search 
where date_part >='2016-01-01' and type = 'txn'
and device_type='desktop' ) and  lob in ('dom flt','intl flt','dom htl', 'intl htl') and date_part>='2016-01-01' and type = 'txn' )a 
where line_of_buss is not null 
group by e,line_of_buss,date)b
group by e,line_of_buss,trnx,visit_month
order by visit_month)q2
on (q1.email=q2.e and q2.quart2=q1.quart1))

union

select *
from
(
(select ceil((visit_month+1)/3) as quart1,email
from
(select email, (datediff(acq_dt,'2016-01-01') DIV 31) as visit_month
from(
select u1.e as email,acq_dt
from(
(select *
from
(
(select e,min(date) as acq_dt,lob
from hydra.txn_search
where date_part>='2016-01-01' and type = 'txn' 
and lob in ('dom htl',
            'intl htl',
            'dom flt',
            'int flt')
group by e,lob)a

inner join
(select e as em,device_type
from hydra.txn_search
where date_part>='2016-01-01' and type = 'txn' and lower(trim(device_type)) = 'desktop' 
and lob in ('dom htl',
            'intl htl',
            'dom flt',
            'int flt')
group by e,device_type)b
on(a.e=b.em))
)u1

inner join
(select e,bkg_id,date
from hydra.txn_search
where date_part >='2016-01-01' and type = 'txn' and lower(trim(device_type)) ='desktop'
group by e, bkg_id,date
order by e)u2

on (u1.e=u2.e)
)
group by email,acq_dt,lob)
group by email,visit_month)
order by ceil((visit_month+1)/3))q1
inner join 
(select e,ceil((visit_month+1)/3) as quart2,line_of_buss,trnx
from
(select e, line_of_buss,count(distinct bkg_id) as trnx , (datediff(date,'2016-01-01') DIV 31) as visit_month
from (select *,
case 
when lob ='dom flt' then 'DF' 
when lob = 'intl flt' then 'IF' 
when lob = 'dom htl' then 'DH' 
when lob = 'intl htl' then 'IH' 
else null 
end as line_of_buss
from hydra.txn_search dfg
where dfg.e in 
(select distinct e 
from hydra.txn_search 
where date_part >='2016-01-01' and type = 'txn'
and device_type='desktop' ) and  lob in ('dom flt','intl flt','dom htl', 'intl htl') and date_part>='2016-01-01' and type = 'txn' )a 
where line_of_buss is not null 
group by e,line_of_buss,date)b
group by e,line_of_buss,trnx,visit_month
order by visit_month)q2
on (q1.email=q2.e and (q2.quart2-q1.quart1) = 1)))

group by quart1,line_of_buss
order by quart1,line_of_buss
))

group by quart1,
         line_of_buss,
         trans,
         gpm
order by quart1,
         line_of_buss
