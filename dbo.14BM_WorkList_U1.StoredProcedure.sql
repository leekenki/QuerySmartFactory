USE [KFQS_MES_2021]
GO
/****** Object:  StoredProcedure [dbo].[14BM_WorkList_U1]    Script Date: 2021-06-22 오후 5:40:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	    
-- Create date: 2021-06-18
-- Description:	검사 항목 마스터 업데이트
-- =============================================
CREATE PROCEDURE [dbo].[14BM_WorkList_U1]
   @PLANTCODE   VARCHAR(10)
  ,@CHECKCODE   VARCHAR(30)
  ,@CHECKNAME  	VARCHAR(30)
  ,@CHECKSPEC  	VARCHAR(30)
  ,@MEASURETYPE	VARCHAR(30)
  ,@MAKER      	VARCHAR(30)
  ,@MAKEDATE   	DATETIME
  ,@EDITOR     	VARCHAR(30)
  ,@EDITDATE   	DATETIME

  ,@LANG    VARCHAR(10) = 'KO'
  ,@RS_CODE VARCHAR(1) OUTPUT
  ,@RS_MSG  VARCHAR(200) OUTPUT
AS
BEGIN

UPDATE TB_CHECKMASTER
   SET CHECKCODE    = @CHECKCODE
      ,CHECKNAME	= @CHECKNAME
      ,CHECKSPEC	= @CHECKSPEC
      ,MEASURETYPE	= @MEASURETYPE
      ,MAKER		= @MAKER
      ,MAKEDATE		= @MAKEDATE
      ,EDITOR		= @EDITOR
      ,EDITDATE		= @EDITDATE
 WHERE PLANTCODE    = @PLANTCODE
   AND CHECKCODE    = @CHECKCODE
   SET @RS_CODE ='S'

END
GO
