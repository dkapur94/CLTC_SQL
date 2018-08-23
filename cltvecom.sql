SELECT ceil((GPM1.VisitMonth+1)/3) as Quart , sum(GPM1.MonthlyVisitors) as QuarterlyVisitors, sum(GPM1.MonthGPM) as QuartGPM  from
(SELECT markOG.vm AS VisitMonth,
   	count(markOG.em) AS MonthlyVisitors,
   	sum(hyd1.smallgpm) AS MonthGPM
FROM
  (SELECT e,
      	sum(gpm_nav) AS smallgpm
   FROM hydra.txn_search
   WHERE date_part>='2015-01-01'
 	AND gpm_nav IS NOT NULL
   GROUP BY e) hyd1
INNER JOIN
  (SELECT Email as em,
      	(datediff(Acqdate,'2015-01-01') DIV 30) AS vm,
      	TotalTxns as tottxns
   FROM
 	(SELECT mark1.email AS Email,
         	mark1.acqdt AS AcqDate,
         	mark2.TotalTxns AS TotalTxns
  	FROM
    	(SELECT email,
            	min(struct(booking_dt,device_omni)).booking_dt AS acqdt,
                                                	min(struct(booking_dt,device_omni)).device_omni AS type_acq
     	FROM marketanalytics.cust_profilesss_apr18_ind
     	WHERE acq_dt>='2015-01-01'
     	GROUP BY email) mark1
  	INNER JOIN
    	(SELECT email,
            	count(*) AS TotalTxns
     	FROM marketanalytics.cust_profilesss_apr18_ind
     	WHERE acq_dt>='2015-01-01'
     	GROUP BY email) mark2 ON (mark1.email=mark2.email)
  	WHERE lower(trim(mark1.type_acq))="desktop")t1) markOG
  	on(lower(trim(markOG.em))=lower(trim(hyd1.e)))
GROUP BY markOG.vm
order by markOG.vm)GPM1
group by Quart
order by Quart
