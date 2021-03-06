USE [KFQS_MES_2021]
GO
/****** Object:  StoredProcedure [dbo].[14AP_ProductPlan_S1]    Script Date: 2021-06-22 오후 5:40:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<이근기>
-- Create date: <2021-06-09 (2)>
-- Description:	<생산계획 및 작업지시 편성 내역조회>
-- =============================================
CREATE PROCEDURE [dbo].[14AP_ProductPlan_S1] 
	@PLANTCODE			VARCHAR(10) -- 공장
	,@WORKCENTERCODE	VARCHAR(10) -- 작업장
	,@ORDERNO			VARCHAR(20) -- 작업지시 번호
	,@ORDERCLOSEFLAG	VARCHAR(1)  -- 작업지시 종료 여부

	,@LANG				VARCHAR(5) = 'KO'
	,@RS_CODE			VARCHAR(1)   OUTPUT
	,@RS_MSG			VARCHAR(200) OUTPUT
AS
BEGIN
	SELECT  PLANTCODE			                    AS PLANTCODE		    -- 공장
		   ,PLANNO				                    AS PLANNO			    -- 계획번호
		   ,ITEMCODE			                    AS ITEMCODE		        -- 품목코드
		   ,PLANQTY				                    AS PLANQTY			    -- 계획수량
		   ,UNITCODE			                    AS UNITCODE		        -- 단위
		   ,WORKCENTERCODE		                    AS WORKCENTERCODE       -- 작업장
		   ,CASE WHEN ISNULL(ORDERFLAG,'N') = 'Y' THEN 1
				 ELSE 0 END		                    AS CHK					-- 선택   
		   ,ORDERNO				                    AS ORDERNO		        -- 작업지시
		   ,ORDERDATE			                    AS ORDERDATE	        -- 확정일시
		   ,DBO.FN_WORKERNAME(ORDERWORKER)			AS ORDERWORKER	        -- 확정자
		   ,ORDERCLOSEFLAG			                AS ORDERCLOSEFLAG		    -- 지시종료 여부
		   ,DBO.FN_WORKERNAME(MAKER)		        AS MAKER				-- 등록자
		   ,CONVERT(VARCHAR, MAKEDATE, 120)         AS MAKEDATE			    -- 등록 일시
		   ,DBO.FN_WORKERNAME(EDITOR)		        AS EDITOR				-- 수정자
		   ,CONVERT(VARCHAR, EDITDATE, 120)         AS EDITDATE		        -- 수정일시 
		    --여기 들어가는 애들은 TB_ProductPlan에 전부 있어야 합니다.
	  FROM TB_ProductPlan WITH(NOLOCK)
	 WHERE PLANTCODE					LIKE '%' + @PLANTCODE			+ '%'
	   AND WORKCENTERCODE				LIKE '%' + @WORKCENTERCODE		+ '%'
	   AND ISNULL(ORDERNO, '')			LIKE '%' + @ORDERNO				+ '%'
	   AND ISNULL(ORDERCLOSEFLAG,'')	LIKE '%' + @ORDERCLOSEFLAG		+ '%'
END
GO
