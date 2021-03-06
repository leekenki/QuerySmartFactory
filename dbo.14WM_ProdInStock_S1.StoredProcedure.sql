USE [KFQS_MES_2021]
GO
/****** Object:  StoredProcedure [dbo].[14WM_ProdInStock_S1]    Script Date: 2021-06-22 오후 5:40:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		이근기
-- Create date: 2021-06-16
-- Description:	제품창고 입고 대상 조회
-- =============================================
CREATE PROCEDURE [dbo].[14WM_ProdInStock_S1]
	 @PLANTCODE     VARCHAR(10)
	,@STARTDATE		VARCHAR(10)
	,@ENDDATE       VARCHAR(10)
	,@ITEMCODE      VARCHAR(30)

	,@LANG VARCHAR(10)    = 'KO'
	,@RS_CODE VARCHAR(1)  OUTPUT
	,@RS_MSG VARCHAR(200) OUTPUT
	
AS
BEGIN
    SELECT 0                                             AS CHK			-- 선택
	      ,A.PLANTCODE								     AS PLANTCODE	-- 공장
		  ,A.LOTNO									     AS LOTNO		-- LOTNO
		  ,A.ITEMCODE								     AS ITEMCODE	-- 품목
		  ,B.ITEMNAME								     AS ITEMNAME	-- 품명
		  ,DBO.FN_CODENAME('ITEMTYPE', B.ITEMTYPE, 'KO') AS ITEMTYPE	-- 품목구분
		  ,DBO.FN_CODENAME('WHCODE', A.WHCODE, 'KO')     AS WHCODE		-- 창고
		  ,A.STOCKQTY									 AS STOCKQTY	-- 수량
		  ,B.BASEUNIT									 AS	UNITCODE	-- 단위
		  ,A.MAKEDATE									 AS	MAKEDATE	-- 생성일시
		  ,A.MAKER										 AS MAKER		-- 생성자
	  FROM TB_StockPP A WITH(NOLOCK) LEFT JOIN TB_ItemMaster B
											ON A.PLANTCODE = B.PLANTCODE
										   AND A.ITEMCODE  = B.ITEMCODE

	 WHERE A.PLANTCODE LIKE '%' + @PLANTCODE + '%'
	   AND A.ITEMCODE  LIKE '%' + @ITEMCODE  + '%'
	   AND A.MAKEDATE  BETWEEN @STARTDATE + ' 00:00:00' AND @ENDDATE + ' 23:59:59'
	   AND B.ITEMTYPE = 'FERT'
END
GO
