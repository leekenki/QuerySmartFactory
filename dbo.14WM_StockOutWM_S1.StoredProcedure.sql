USE [KFQS_MES_2021]
GO
/****** Object:  StoredProcedure [dbo].[14WM_StockOutWM_S1]    Script Date: 2021-06-22 오후 5:40:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		이근기
-- Create date: 2021-06-17
-- Description:	제품 출고 대상 상차 공통 내역 조회
-- =============================================
CREATE PROCEDURE [dbo].[14WM_StockOutWM_S1]
		@PLANTCODE VARCHAR(10) --공장
	   ,@CUSTCODE  VARCHAR(10) --거래처 코드
	   ,@STARTDATE VARCHAR(10) --조회 시작일자
	   ,@ENDDATE   VARCHAR(10) --조회 종료일자
	   ,@CARNO     VARCHAR(20) --차량번호
	   ,@SHIPNO    VARCHAR(30) --상차번호

	   ,@LANG      VARCHAR(10)  ='KO'
	   ,@RS_CODE   VARCHAR(1)   OUTPUT
	   ,@RS_MSG    VARCHAR(200) OUTPUT
AS
BEGIN
	SELECT 0				AS CHK        
		  ,PLANTCODE		AS PLANTCODE
		  ,SHIPNO			AS SHIPNO	
		  ,SHIPDATE			AS SHIPDATE	
		  ,CARNO     		AS CARNO    
		  ,CUSTCODE   		AS CUSTCODE 
		  ,DBO.FN_CUSTNAME(PLANTCODE, CUSTCODE) AS CUSTNAME		
		  ,WORKER			AS WORKER		
		  ,TRADINGNO 		AS TRADINGNO 	
		  ,TRADINGDATE		AS TRADINGDATE	
		  ,MAKEDATE  		AS MAKEDATE  	
		  ,MAKER     		AS MAKER     	
		  ,EDITDATE  		AS EDITDATE  	
		  ,EDITOR  			AS EDITOR  		
	  FROM TB_ShipWM WITH(NOLOCK)
	 WHERE PLANTCODE LIKE '%' + @PLANTCODE + '%'
	   AND CUSTCODE  LIKE '%' + @CUSTCODE + '%'
	   AND CARNO     LIKE '%' + @CARNO + '%'
	   AND SHIPNO    LIKE '%' + @SHIPNO + '%'
	   AND SHIPDATE  BETWEEN @STARTDATE AND @ENDDATE
	   AND TRADINGNO IS NULL

END
GO
