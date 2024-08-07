USE [DAQ-1445_Contiki_App_DESQL016_Divestment]
GO
/****** Object:  StoredProcedure [dbo].[Takeda_Maintenance_DeleteOldUnattachedUsers]    Script Date: 24 Jun 2024 11:12:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[Takeda_Maintenance_DeleteOldUnattachedUsers]

as

/*
select * INTO T_Takeda_UserID_CountractRoleCount_VUSER
FROM dbo.V_Takeda_UserID_CountractRoleCount_VUSER

missing: taudittrail, taudittrailhistory, thistory
*/

/*
select * from TAUDITTRAIL
WHERE USERID in (select userid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)

select * from taudittrail_history
WHERE USERID in (select userid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)

select * from thistory
WHERE USERID in (select userid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)

*/

delete from TUSER_IN_USERGROUP 
WHERE USERID in (select userid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)

delete from TLOGON
where USERID in (select userid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)

delete from TUSER_IN_CONTRACT
WHERE USERID in (select userid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)

delete from TOBJECTHISTORY
WHERE USERID in (select userid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)

delete from TNOTE_IN_OBJECT
WHERE noteid in (select noteid from tnote 
where userid in (select userid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL))

delete from TNOTE
WHERE USERID in (select userid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)

update TFILEINFO
set LastChangedBy = 1
WHERE LastChangedBy in (select userid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)

update TPOST
set CREATEDBYUSERID = 1
where CREATEDBYUSERID in (select userid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)

delete from TPROFILESETTING
WHERE USERID in (select userid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)

delete from TSEARCHFAVOURITE
WHERE SEARCHFAVOURITE_USERID in (select userid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)

delete from dbo.TMESSAGE
where SenderUserId in (select userid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)
or ReceiverUserId in (select userid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL) 

delete from TMESSAGESESSION
WHERE ParticipantUserId in (select userid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)
or CreatorUserId in (select userid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)

delete from tuser
WHERE USERID in (select userid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)

delete from TEMPLOYEERELATION
WHERE INFERIOREMPLOYEEID in (select employeeid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)
OR MANAGEREMPLOYEEID in (select employeeid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)

delete from temployee 
WHERE employeeid in (select employeeid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)

/*
update TCONTRACT
set ownerid = 0
where ownerid in (select employeeid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)


select COUNT(*) from tuser
2404
*/


Update TPERSONROLE_IN_OBJECT /* includes amendments etc. - use admin */
set PERSONID = 1
WHERE personid in (select personid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)

/* mostly personroleid 16 = everyone NOT YET DONE */
delete from dbo.TPERSONROLE_IN_OBJECTTYPE
WHERE personid in (select personid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)

/* select COUNT(*) from TPERSONROLE_IN_OBJECTTYPE where ROLEID = 16

select * from TCONTRACT where contractid = 101798
select * from TACL where OBJECTID = 101798
select * from VUSER where DISPLAYNAME like '%joest%'

select * from TPERSONROLE_IN_OBJECTtype
WHERE /* personid in (select personid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL) */
PERSONID = 34530
*/

/*
delete from TPERSONROLE_IN_OBJECT
WHERE PERSONID not in (select PERSONID from VUSER)

delete from dbo.TPERSONROLE_IN_OBJECTTYPE
WHERE PERSONID not in (select PERSONID from VUSER)
*/

DELETE from tperson
WHERE PERSONID not in (select PERSONID from VUSER)
and PERSONID not in (select PERSONID from TCOMPANYCONTACT)
and PERSONID not in (select PERSONID from TPERSON_IN_WARNING)
and PERSONID not in (select PERSONID from TEMPLOYEE)
and PERSONID not in (select PERSONID from dbo.TCONSULTANT)
and PERSONID IN (select personid from V_Takeda_UserID_CountractRoleCount_VUSER_DEL)

/* delete from TACL /* this also deletes super user permissions which then cannot be transferred */
where USERID not in (select USERID from TUSER where MIK_VALID = 1) */

GO
