USE [KFQS_MES_2021]
GO
/****** Object:  StoredProcedure [dbo].[14PP_WCTRunStopList_U1]    Script Date: 2021-06-22 오후 5:40:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*---------------------------------------------------------------------------------------------*
  PROEDURE ID    : PP_WCTRunStopList_U1
  PROCEDURE NAME : 작업장 기간별 가동/비가동 현황 등록
  ALTER DATE     : 2020.08
  MADE BY        : LKK
  DESCRIPTION    : 
  REMARK         : 
*---------------------------------------------------------------------------------------------*
  ALTER DATE     :
  UPDATE BY      :
  REMARK         :
*---------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[14PP_WCTRunStopList_U1]
(
      @PLANTCODE       VARCHAR(10)    -- 공장
	 ,@WORKCENTERCODE  VARCHAR(10)    -- 작업장
	 ,@ORDERNO   	   VARCHAR(20)    -- 작업지시 번호
	 ,@RSSEQ    	   INT            -- 작업장지시별 순번
	 ,@REMARK          VARCHAR(200)   -- 비가동 사유
	 ,@EDITOR          VARCHAR(20)    -- 사유 등록자

     ,@LANG            VARCHAR(10)  ='KO'
     ,@RS_CODE         VARCHAR(1)   OUTPUT
     ,@RS_MSG          VARCHAR(200) OUTPUT
)
AS
BEGIN
     UPDATE TP_WorkcenterStatusRec
	    SET REMARK        = @REMARK
		   ,EDITDATE      = GETDATE()
		   ,EDITOR        = @EDITOR
	 WHERE PLANTCODE      = @PLANTCODE
	   AND WORKCENTERCODE = @WORKCENTERCODE
	   AND ORDERNO        = @ORDERNO
	   AND RSSEQ          = @RSSEQ
 
	SET @RS_CODE = 'S'
END
GO
