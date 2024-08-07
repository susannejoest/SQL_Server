USE [DAQ-1445_Contiki_App_DESQL016_Divestment]
GO
/****** Object:  StoredProcedure [dbo].[TheCompany_2WEEKLY_RemapTT_IPToTT]    Script Date: 24 Jun 2024 11:12:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TheCompany_2WEEKLY_RemapTT_IPToTT]

/* Issue #341 - Remap TERRITORY field Internal Partner AND Department to Region Territory value */

/* Create Temp Mapping Table #tmp_dbo_tdptroleinobject */

AS

BEGIN

/* Create temp table */

	SELECT m.*, t.TargetDptID 
	into #tmp_dbo_tdptroleinobject
	FROM (SELECT o.OBJECTID
	, r.role 
	, r.roleid
	, d.department
	, d.departmentid as OrigDptID
	, d.department_code 
	, SUBSTRING(d.department_code,2,2) ctry2Digit

	FROM TDEPARTMENTROLE_IN_OBJECT o, TDEPARTMENT d, TROLE r
	WHERE r.roleid = o.roleid
	and d.departmentid = o.departmentid
	and (d.department_code like (',%') /*Internal Partner*/ OR d.department_code like ('.%') /*Department*/)
	and r.roleid =3 /*Territories*/) m,

	(SELECT 
	u.DEPARTMENTID TargetDptID
	, u.USERGROUP
	, d.department_code
	, SUBSTRING(d.department_code,2,2) as TargetCtry2Digit
	FROM TUSERGROUP u, TDEPARTMENT d
	WHERE 
	d.departmentid = u.departmentid
	and u.mik_valid = 1
	AND u.USERGROUP LIKE 'Territories - Region%') t
	WHERE m.ctry2Digit = t.TargetCtry2Digit

/* Update TDEPARTMENTROLE_IN_OBJECT' */

	UPDATE d
	set d.DEPARTMENTID = t.TargetDptID
	FROM TDEPARTMENTROLE_IN_OBJECT d
	inner join #tmp_dbo_tdptroleinobject t
	on d.DEPARTMENTID = t.OrigDptID
	and t.objectid = d.objectid
	and d.roleid = 3 /*Territories*/

	PRINT '[dbo].[Takeda_341_RemapTT_InternalPartnerToTerritory] Result: ' + Convert(Varchar(12),@@ROWCOUNT) + ' Rows Affected'

/* Drop temp table #tmp_dbo_tdptroleinobject' */

	drop table #tmp_dbo_tdptroleinobject

/* delete duplicate territory entries that might be created after the update above */

DELETE FROM TDEPARTMENTROLE_IN_OBJECT WHERE [DEPARTMENTROLE_IN_OBJECTID] IN 
(
SELECT  MAX(DEPARTMENTROLE_IN_OBJECTID) 
from TDEPARTMENTROLE_IN_OBJECT
where roleid = 3 /* Territories */
group by OBJECTTYPEID, OBJECTID, DEPARTMENTID, ROLEID
HAVING COUNT(*)>1
)

END
GO
