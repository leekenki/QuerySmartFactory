USE [KFQS_MES_2021]
GO
/****** Object:  StoredProcedure [dbo].[14WM_TradingManager_S3]    Script Date: 2021-06-22 오후 5:40:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		이근기
-- Create date: 2021-06-21
-- Description: 출하 거래 명세서 출력
-- =============================================
CREATE PROCEDURE [dbo].[14WM_TradingManager_S3]
	@PLANTCODE VARCHAR(10)
   ,@TRADINGNO VARCHAR(30)

   ,@LANG      VARCHAR(10) = 'KO'
   ,@RS_CODE   VARCHAR(1)   OUTPUT
   ,@RS_MSG    VARCHAR(200) OUTPUT
AS
BEGIN
    --상세테이블을 베이스로 나머지를 살 붙여서 보여줄 것.
	SELECT A.TRADINGSEQ                                 AS ROWNO
	      ,A.TRADINGNO                                  AS TRADINGNO
		  ,A.ITEMCODE                                   AS ITEMCODE
		  ,DBO.FN_ITEMNAME(A.ITEMCODE,A.PLANTCODE,'KO') AS ITEMNAME  --왜 이것만 펑션썻지?
		  ,LOTNO										AS LOTNO
		  ,A.TRADINGQTY                                 AS TRADINGQTY
		  ,DBO.FN_CUSTNAME(A.PLANTCODE,B.CUSTCODE)      AS CUSTNAME
		  ,DBO.FN_WORKERNAME(A.MAKER)                   AS MAKER
		  ,B.CARNO                                      AS CARNO
		  ,CONVERT(VARCHAR,A.MAKEDATE,120)              AS MAKEDATE
	  FROM TB_TradingWM_B A WITH(NOLOCK) LEFT JOIN TB_ShipWM B WITH(NOLOCK) --상차등록된 업체정보받아와야합니다. 그래서 상차번호를 가져와서 거래처를 받아오겠습니다.
	                                            ON A.PLANTCODE = B.PLANTCODE
											   AND A.SHIPNO    = B.SHIPNO
											   -- 뒤에 있는게 상차실적 공통테이블임. 앞은 상세테이블이고
	 WHERE A.PLANTCODE = @PLANTCODE
	   AND A.TRADINGNO = @TRADINGNO
END
GO
