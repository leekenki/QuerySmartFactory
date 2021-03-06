USE [KFQS_MES_2021]
GO
/****** Object:  StoredProcedure [dbo].[14BM_WorkList_S1]    Script Date: 2021-06-22 오후 5:40:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[14BM_WorkList_S1]
	@PLANTCODE  VARCHAR(10),			--공장코드
	@WORKERID   VARCHAR(20),			--작업자 아이디
	@WORKERNAME VARCHAR(20),		--작업자명
	@BANCODE    VARCHAR(10),			--작업반
	@USEFLAG   VARCHAR(10),			--사용여부

	@LANG		VARCHAR(10) = 'KO',		--언어(패키지솔루션에잇음)
	@RS_CODE    VARCHAR(10) OUTPUT,	--성공여부(패키지솔루션에잇음)
	@RS_MSG		VARCHAR(200) OUTPUT		--성공관련 매세지(패키지솔루션에잇음)
AS
BEGIN
	SELECT A.PLANTCODE,	--공장
		   A.WORKERID,	--작업자 ID
		   A.WORKERNAME,	--작업자 명
		   A.BANCODE,		--작업반
		   A.GRPID,		--그룹아이디
		   A.DEPTCODE,	--부서코드
		   A.PHONENO,		--연락처
		   A.INDATE,		--입사일
		   A.OUTDATE,		--퇴사일자
		   A.USEFLAG,		--사용여부
		   DBO.FN_WORKERNAME(A.MAKER)  AS MAKER,	--등록자
		   A.MAKEDATE,		--등록일시
		   DBO.FN_WORKERNAME(A.EDITOR) AS EDITOR,	--수정자
		   A.EDITDATE		--수정일시
	  FROM TB_WorkerList A WITH(NOLOCK) --습관들일것!
	 WHERE @PLANTCODE			LIKE '%' + @PLANTCODE + '%'
	   AND A.WORKERID			LIKE '%' + @WORKERID + '%'
	   AND A.WORKERNAME			LIKE '%' + @WORKERNAME + '%'
	   AND ISNULL(A.BANCODE,'') LIKE '%' + @BANCODE + '%'
	   AND A.USEFLAG			LIKE '%' + @USEFLAG + '%'

END
GO
