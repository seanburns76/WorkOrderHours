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
--group by
x.[Week Start Date],
x.[Work Center],
x.[Work Center Description],
x.[Work Center Type],
x.[Deparment ID],
x.[Department Description],

--summations
sum(x.[Standard Machine Hours]) as [Standard Machine Hours],
sum(x.[Standard Labor Hours]) as [Standard Labor Hours],
sum(x.[Standard Total Hours]) as [Standard Total Hours],
sum(x.[Actual Machine Hours]) as [Actual Machine Hours],
sum(x.[Actual Labor Hours]) as [Actual Labor Hours],
sum(x.[Actual Total Hours]) as [Actual Total Hours],
sum(x.[Setup Hours]) as [Setup Hours],
sum(x.[Actual - Standard Hours]) as [Actual - Standard Hours],
sum(x.[Planned Machine Hours]) as [Planned Machine Hours],
sum(x.[Planned Labor Hours]) as [Planned Labor Hours],
sum(x.[Planned WO Labor Hours]) as [Planned WO Labor Hours],
sum(x.[Planned Crew Size]) as [Planned Crew Size],
sum(x.[Planned Machine Hours]) as [Planned Total Machine Hours],
sum(x.[Planned Total Machine Hours]) as [Planned Total Labor Hours],
sum(x.[Actual WO Labor Hours]) as [Actual WO Labor Hours]
from 
(
select
--Dimensions & Attributes 

dateadd(dd,-(DATEPART(dw,wc.[Ops Date]))+1,wc.[Ops Date]) as [Week Start Date],
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
) x

group by 
x.[Week Start Date],
x.[Work Center],
x.[Work Center Description],
x.[Work Center Type],
x.[Deparment ID],
x.[Department Description]
