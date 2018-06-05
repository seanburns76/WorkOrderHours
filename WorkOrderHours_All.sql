set datefirst 1;
with wc as (
select 
w.WLMCU as [Work Center],
w.OPSDATE as [Ops Date],
mw.WorkCenterDesc as [Work Center Description],
mw.DepartmentDesc,
mw.DepartmentCode,
mw.WorkCenterType ,
w.WLDOCO as [Work Order]   ,
case 
	when w.RUNMACH = 0 or WLMCU in ('53001C','53002C','53003C','52003C','52004C','52005C')  
		then 0 else w.STDCOMHRS end
				as [Standard Machine Hours],
case 
	when w.RUNLAB = 0 or WLMCU in ('53001C','53002C','53003C','52003C','52004C','52005C')  
		then 0 else w.STDCOMHRS end
				as [Standard Labor Hours],
case 
	when mw.WorkCenterType = 'Machine' then w.ACTHRS else 0 end as [Actual Machine Hours],
case 
	when mw.WorkCenterType = 'Labor' then w.ACTHRS else 0 end as [Actual Labor Hours],
case 
	when w.RUNMACH = 0 or WLMCU in ('53001C','53002C','53003C','52003C','52004C','52005C','58094')  
		then 0 else w.WOHRS end
				as [Planned Machine Hours],
case 
	when w.RUNLAB = 0 or WLMCU in ('53001C','53002C','53003C','52003C','52004C','52005C')  
		then 0 else w.WOHRS end
				as [Planned Labor Hours],
case 
	when w.WLMCU in ('53001C','53002C','53003C','52003C','52004C','52005C'
)  
		then w.WOHRS else 0 end
				as [Planned WO Labor Hours],
w.SETUP as [Setup Hours],
mw.PlannedCrewSize as [Planned Crew Size],
case 
	when w.WLMCU in ('53001C','53002C','53003C','52003C','52004C','52005C','58094')  
		then w.ACTHRS else 0 end
				as [Actual WO Labor Hours]



from WorkOrder_Hours w left join Meta_Data.dbo.Meta_WorkCenter mw on mw.WorkCenterNum=w.WLMCU

)

select
--Dimensions & Attributes 
wc.[Ops Date],
dateadd(dd,-(DATEPART(dw,wc.[Ops Date]))+2,wc.[Ops Date]) as [Week Start Date],
wc.[Work Order],
wc.[Work Center],
wc.WorkCenterType as [Work Center Type],
wc.[Work Center Description],
wc.DepartmentCode as [Deparment ID],
wc.DepartmentDesc as [Department Description],

--Standard Hours(Not Extended)
wc.[Standard Machine Hours],
wc.[Standard Labor Hours],
wc.[Standard Labor Hours]+wc.[Standard Machine Hours] as [Standard Total Hours],

--Actual Hours(Not Extended)
wc.[Actual Machine Hours],
wc.[Actual Labor Hours],
wc.[Actual Labor Hours]+wc.[Actual Machine Hours] as [Actual Total Hours],
wc.[Setup Hours],
(wc.[Actual Labor Hours]+wc.[Actual Machine Hours]) - (wc.[Standard Labor Hours]+wc.[Standard Machine Hours]) as [Actual - Standard Hours],



--Planned Hours(Earned Hours)
wc.[Planned Machine Hours],
wc.[Planned Labor Hours],
wc.[Planned WO Labor Hours],

wc.[Planned Crew Size],
case
	when wc.WorkCenterType = 'Machine' then (wc.[Planned Machine Hours]+wc.[Setup Hours]) * wc.[Planned Crew Size]
		else 0 end as [Planned Total Machine Hours],
case when wc.WorkCenterType = 'Labor' then wc.[Planned Labor Hours]+wc.[Setup Hours]+wc.[Planned WO Labor Hours]
		else 0 end as [Planned Total Labor Hours],

--JDE Actual Hours totals ****Not duplicating "Actual Hours(Not Extended) from above

wc.[Actual WO Labor Hours]

from wc
where wc.[Ops Date] between '2018-02-26' and '2018-03-04' and wc.[Work Center] = '52004'
order by wc.[Standard Machine Hours]

