USE [KFQS_MES_2021]
GO
/****** Object:  StoredProcedure [dbo].[14WM_TradingManager_S2]    Script Date: 2021-06-22 오후 5:40:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		이근기
-- Create date: 2021-06-17
-- Description:	출고 내역 공통(거래면세 상세) 조회
-- =============================================
CREATE PROCEDURE  [dbo].[14WM_TradingManager_S2]
    @PLANTCODE VARCHAR(10) -- 공장
   ,@TRADINGNO VARCHAR(30) -- 거래명세 번호
   
   ,@LANG      VARCHAR(10) = 'KO'
   ,@RS_CODE   VARCHAR(1)   OUTPUT
   ,@RS_MSG    VARCHAR(200) OUTPUT
AS
BEGIN
	SELECT A.PLANTCODE			AS PLANTCODE
	      ,A.TRADINGNO			AS TRADINGNO
		  ,A.TRADINGSEQ			AS TRADINGSEQ
		  ,A.SHIPNO				AS SHIPNO
		  ,A.SHIPSEQ			AS SHIPSEQ
		  ,C.CUSTCODE			AS CUSTCODE
		  ,D.CUSTNAME			AS CUSTNAME
		  ,C.WORKER				AS WORKER
		  ,E.WORKERNAME			AS WORKERNAME
		  ,A.LOTNO				AS LOTNO
		  ,A.ITEMCODE			AS ITEMCODE
		  ,B.ITEMNAME			AS ITEMNAME
		  ,A.TRADINGQTY			AS TRADINGQTY
		  ,B.BASEUNIT			AS BASEUNIT
		  ,A.MAKEDATE			AS MAKEDATE
	 FROM TB_TradingWM_B A WITH(NOLOCK) LEFT JOIN TB_ItemMaster B WITH(NOLOCK)
										       ON A.PLANTCODE = B.PLANTCODE
											  AND A.ITEMCODE  = B.ITEMCODE
										LEFT JOIN TB_ShipWM     C WITH(NOLOCK)
										       ON A.PLANTCODE = C.PLANTCODE
											  AND A.SHIPNO    = C.SHIPNO
										LEFT JOIN TB_CustMaster D WITH(NOLOCK)
											   ON C.PLANTCODE = D.PLANTCODE
											  AND C.CUSTCODE  = D.CUSTCODE
										LEFT JOIN TB_WorkerList E WITH(NOLOCK)
										       ON C.PLANTCODE = E.PLANTCODE
										      AND C.WORKER    = E.WORKERID
	WHERE A.PLANTCODE = @PLANTCODE
	  AND A.TRADINGNO = @TRADINGNO
END

GO
