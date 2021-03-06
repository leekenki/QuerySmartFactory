USE [KFQS_MES_2021]
GO
/****** Object:  StoredProcedure [dbo].[14MM_PoMake_D1]    Script Date: 2021-06-22 오후 5:40:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[14MM_PoMake_D1]
   @PLANTCODE VARCHAR(10),       --공장 코드
   @CUSTCODE  VARCHAR(20),       --거래처 코드
   @PONO      VARCHAR(30),       --발주번호
   @STARTDATE VARCHAR(10),       --시작일자
   @ENDDATE   VARCHAR(10),       --종료일자

   @LANG VARCHAR(10) = 'KO',     --언어
   @RS_CODE VARCHAR(10) OUTPUT,  --성공 여부
   @RS_MSG VARCHAR(200) OUTPUT   --성공 관련 메세지

AS
BEGIN 
  IF ( SELECT ISNULL(INFLAG, 'N')
		FROM TB_POMake WITH(NOLOCK)
	   WHERE PLANTCODE = @PLANTCODE
	     AND PONO      = @PONO) = 'Y'
BEGIN
SET @RS_CODE = 'E'
SET @RS_MSG = '이미입고된 발주입니다.'
RETURN;
END
      DELETE TB_POMake
	  WHERE PLANTCODE = @PLANTCODE
	  AND PONO = @PONO;

	  SET @RS_CODE = 'S'
 
      
END          
GO
