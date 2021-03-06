USE [KFQS_MES_2021]
GO
/****** Object:  StoredProcedure [dbo].[14MM_StockMM_S1]    Script Date: 2021-06-22 오후 5:40:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*---------------------------------------------------------------------------------------------*
  PROEDURE ID    : MM_StockMM_S1
  PROCEDURE NAME : 자재 재고 조회
  ALTER DATE     : 2021-06-12
  MADE BY        : LKK
  DESCRIPTION    : 
  REMARK         : 
*---------------------------------------------------------------------------------------------*
  ALTER DATE     :
  UPDATE BY      :
  REMARK         :
*---------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[14MM_StockMM_S1]
(
      @PLANTCODE       VARCHAR(10)    -- 공장
     ,@ITEMCODE        VARCHAR(30)    -- 품목
     ,@LOTNO           VARCHAR(30)    -- LOTNO
     ,@LANG            VARCHAR(10)='KO'
     ,@RS_CODE         VARCHAR(1) OUTPUT
     ,@RS_MSG          VARCHAR(200) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;   -- 영향을 받지 않는 테이블의 처리 결과 표시 제거.
    BEGIN TRY

      BEGIN
        SELECT A.PLANTCODE AS PLANTCODE
		      ,A.ITEMCODE  AS ITEMCODE
			  ,B.ITEMNAME  AS ITEMNAME
			  ,A.MATLOTNO  AS MATLOTNO
			  ,A.WHCODE    AS WHCODE
			  ,A.STOCKQTY  AS STOCKQTY
			  ,A.UNITCODE  AS UNITCODE
			  ,A.CUSTCODE  AS CUSTCODE
			  ,C.CUSTNAME  AS CUSTNAME
		  FROM TB_StockMM A WITH (NOLOCK) LEFT JOIN TB_ItemMaster B WITH (NOLOCK) 
												 ON A.PLANTCODE = B.PLANTCODE
												AND A.ITEMCODE  = B.ITEMCODE
										  LEFT JOIN TB_CustMaster C WITH (NOLOCK)
										         ON A.PLANTCODE = C.PLANTCODE
												AND A.CUSTCODE  = C.CUSTCODE
		 WHERE A.PLANTCODE LIKE '%' + @PLANTCODE + '%'
		   AND A.ITEMCODE  LIKE '%' + @ITEMCODE  + '%'
		   AND A.MATLOTNO  LIKE '%' + @LOTNO     + '%'


     END
           
      
    SELECT @RS_CODE = 'S'

    END TRY

    BEGIN CATCH
        INSERT INTO ERRORMESSAGE ( NAME, ERROR, ELINE, MESSAGE, DATE )
			SELECT ERROR_PROCEDURE() AS ERRORPROCEDURE
				 , ERROR_NUMBER()    AS ERRORNUMBER
				 , ERROR_LINE()      AS ERRORLINE
				 , ERROR_MESSAGE()   AS ERRORMESSAGE
				 , GETDATE()
		
		SELECT @RS_CODE = 'E'
		SELECT @RS_MSG = ERROR_MESSAGE()
    END CATCH
END




GO
