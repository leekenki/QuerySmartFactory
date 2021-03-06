USE [KFQS_MES_2021]
GO
/****** Object:  StoredProcedure [dbo].[14PP_ActureOutput_U1]    Script Date: 2021-06-22 오후 5:40:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		이근기
-- Create date: 2021-06-11
-- Description:	가동/비가동 등록
-- =============================================
CREATE PROCEDURE [dbo].[14PP_ActureOutput_U1]
        @PLANTCODE       VARCHAR(10)    -- 공장
       ,@WORKCENTERCODE  VARCHAR(10)    -- 작업장
       ,@ORDERNO         VARCHAR(20)    -- 작업지시
       ,@ITEMCODE        VARCHAR(30)    -- 생산 품목
       ,@UNITCODE        VARCHAR(10)     -- 생산 단위
       ,@STATUS          VARCHAR(1)     -- 상태
       ,@LANG            VARCHAR(10)  ='KO'
       ,@RS_CODE         VARCHAR(1)   OUTPUT
       ,@RS_MSG          VARCHAR(200) OUTPUT

AS
BEGIN

    -- 시간 정의
		DECLARE @LD_NOWDATE  DATETIME
		       ,@LS_NOWDATE  VARCHAR(10)
			   ,@LS_WORKER   VARCHAR(20)
		    SET @LD_NOWDATE  = GETDATE()
		    SET @LS_NOWDATE  = CONVERT(VARCHAR,@LD_NOWDATE,23)

		DECLARE @LS_ITEMCODE VARCHAR(30)  -- 작업지시 품목
		       ,@LF_STOCKQTY FLOAT	      -- 작업수량
			   ,@LS_UNITCODE VARCHAR(10)  -- 단위 
			   ,@INOUTSEQ    INT          -- 이력 시퀀스


	-- 작업자 등록 여부 가져오기
	SELECT @LS_WORKER = WORKER
	  FROM TP_WorkcenterStatus WITH(NOLOCK)
	 WHERE PLANTCODE		= @PLANTCODE
	   AND WORKCENTERCODE   = @WORKCENTERCODE
	   AND ORDERNO			= @ORDERNO
	IF (ISNULL(@LS_WORKER, '') = '')
	BEGIN
		SET @RS_CODE = 'E'
		SET @RS_MSG  = '투입 작업자의 정보가 없습니다.'
		RETURN;
	END


	-- 선택 작업장이 가동중인지 확인
	IF(SELECT COUNT(*)
	     FROM TP_WorkcenterStatus WITH(NOLOCK)
		WHERE PLANTCODE			= @PLANTCODE  --내가 선택한 코드에서 가져옴
		  AND WORKCENTERCODE	= @ORDERNO    --내가 선택한 오더넘버에서 부터 가져옴.
		  AND ORDERNO			<> @ORDERNO
		  AND STATUS			= 'R') <> 0  --작업장에 자기 작업번호가 아닌것이 있으면(가중동이 아니면) 튕김
	BEGIN
		SET @RS_CODE = 'E'
		SET @RS_MSG  = '해당 작업장에 가동이 진행중인 작업지시가 있습니다.'
		RETURN
	END


	-- 최초 가동시작일 경우 가동 시간 등록
	UPDATE TP_WorkcenterStatus -- 작업장 작업지시 별 상태 테이블(현재상태만 보여주는 테이블. 즉 휘발성 테이블입니다.)
	   SET STATUS  = @STATUS  --계속 업데이트 해주는데 이 상태는 소스에서 받아옴. 이걸 호출하기 전에!
	      ,ORDSTARTDATE = CASE WHEN ORDSTARTDATE IS NULL --최초로 누가 가동을 햇을때,
		                       THEN @LS_NOWDATE ELSE ORDSTARTDATE END  --원래있던 ORDERSTARTDATE의 값을 그대로 넣어라.
     WHERE PLANTCODE		 = @PLANTCODE
	   AND WORKCENTERCODE    = @WORKCENTERCODE
	   AND ORDERNO			 = @ORDERNO  -- 예내 셋은 키!입니다.


    -- 작업장 별 가동 현황 테이블 TP_WorkercenterStatusREC 
	DECLARE @LI_RSSEQ INT
	 SELECT @LI_RSSEQ        = ISNULL(MAX(RSSEQ),0)  --(???????) 이건 진짜 햇갈리네. 왜 채번이 안되는거지?
	   FROM TP_WorkcenterStatusRec WITH(NOLOCK)
	  WHERE PLANTCODE        = @PLANTCODE
	    AND WORKCENTERCODE   = @WORKCENTERCODE
		AND ORDERNO          = @ORDERNO


	-- 이전 가동 정보 업데이트
	UPDATE TP_WorkcenterStatusRec
	   SET RSENDDATE	  = @LD_NOWDATE
	      ,EDITDATE		  = @LD_NOWDATE
		  ,EDITOR		  = @LS_WORKER
	 WHERE PLANTCODE	  = @PLANTCODE
	   AND WORKCENTERCODE = @WORKCENTERCODE
	   AND ORDERNO		  = @ORDERNO
	   AND RSSEQ		  = @LI_RSSEQ -- 만약 아무것도 안햇으면 여기 0이 들어갔겠지

	-- 새로운 가동 상태 인서트
	   SET @LI_RSSEQ = @LI_RSSEQ +1
	   INSERT INTO TP_WorkcenterStatusRec (PLANTCODE, WORKCENTERCODE, ORDERNO, RSSEQ, 
										   WORKER, ITEMCODE, STATUS, RSSTARTDATE,      --RSSTARTDATE는 시작일시
										   MAKER, MAKEDATE)
								   VALUES ( @PLANTCODE, @WORKCENTERCODE, @ORDERNO, @LI_RSSEQ, 
								           @LS_WORKER, @ITEMCODE, @STATUS, @LD_NOWDATE,
										   @LS_WORKER, @LD_NOWDATE)
	   SET @RS_CODE = 'S'

END
GO
