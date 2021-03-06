USE [KFQS_MES_2021]
GO
/****** Object:  StoredProcedure [dbo].[14PP_ActureOutput_U2]    Script Date: 2021-06-22 오후 5:40:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		이근기
-- Create date: 2021-06-14
-- Description:	생산 실적 등록
-- =============================================
CREATE PROCEDURE [dbo].[14PP_ActureOutput_U2]
	@PLANTCODE      VARCHAR(10) -- 공장
   ,@WORKCENTERCODE VARCHAR(10) -- 작업장
   ,@ORDERNO		VARCHAR(30) -- 작업지시 번호
   ,@ITEMCODE		VARCHAR(30) -- 품목 코드
   ,@UNITCODE       VARCHAR(10) -- 단위
   ,@PRODQTY        FLOAT       -- 양품 수량
   ,@ERRORQTY       FLOAT       -- 불량 수량
   ,@MATLOTNO	    VARCHAR(30) -- 투입 LOT
   ,@CITEMCODE      VARCHAR(30) -- 투입 품목
   ,@CUNITCODE      VARCHAR(10) -- 투입 품목 단위

   ,@LANG            VARCHAR(10)    ='KO'
   ,@RS_CODE         VARCHAR(1)     OUTPUT
   ,@RS_MSG		     VARCHAR(200)   OUTPUT


AS
BEGIN
    -- 현재 시간 정의
	DECLARE @LD_NOWDATE DATETIME
           ,@LS_NOWDATE VARCHAR(10)
		   ,@LS_WORKER  VARCHAR(20)
		SET @LD_NOWDATE = GETDATE()  
        SET @LS_NOWDATE = CONVERT(VARCHAR,@LD_NOWDATE,23)
	DECLARE @INOUTSEQ INT

	-- 작업장 등록 작업자 정보 조회
	SELECT @LS_WORKER = WORKER
      FROM TP_WorkcenterStatus WITH(NOLOCK)
	 WHERE PLANTCODE      = @PLANTCODE
	   AND WORKCENTERCODE = @WORKCENTERCODE
	   AND ORDERNO        = @ORDERNO
	IF (ISNULL(@LS_WORKER,'') = '')
	BEGIN
		SET @RS_CODE = 'E'
		SET @RS_MSG  = '작업장 투입 작업자가 없습니다.'
		RETURN
	END	

	-- BOM 수량만큼 투입 잔량이 남아있는지 확인.
	DECLARE @LF_TOTALQTY FLOAT
	       ,@LF_FINALQTY FLOAT
		   ,@LF_PRODQTY  FLOAT

	   SET @LF_TOTALQTY = ISNULL(@PRODQTY,0) + ISNULL(@ERRORQTY,0)

    -- BOM 테이블 확인 및 투입(차감) 되어야 할 수량 확인
	SELECT @LF_FINALQTY = ISNULL(COMPONENTQTY,1) * @LF_TOTALQTY
	      ,@LF_PRODQTY  = ISNULL(COMPONENTQTY,1) * ISNULL(@PRODQTY,0)
	  FROM TB_BomMaster WITH(NOLOCK)
	 WHERE PLANTCODE = @PLANTCODE    -- 공장
	   AND ITEMCODE  = @ITEMCODE     -- 상위 품목
	   AND COMPONENT = @CITEMCODE    -- 하위 품목
	SET @LF_FINALQTY = ISNULL(@LF_TOTALQTY,@LF_TOTALQTY);


	IF (SELECT STOCKQTY
	      FROM TB_StockHALB WITH(NOLOCK)
		 WHERE PLANTCODE = @PLANTCODE
		   AND LOTNO     = @MATLOTNO) < @LF_FINALQTY
    BEGIN
		SET @RS_CODE = 'E'
		SET @RS_MSG  = '투입 잔량이 부족합니다.'
		RETURN
	END

	-- 현재 작업장 상태 테이블 생산 정보 등록
	UPDATE TP_WorkcenterStatus
	   SET PRODQTY       = ISNULL(PRODQTY,0)      + @PRODQTY
	      ,BADQTY        = ISNULL(BADQTY,0)       + @ERRORQTY
		  ,COMPONENTQTY	 = ISNULL(COMPONENTQTY,0) - @LF_FINALQTY
    WHERE PLANTCODE      = @PLANTCODE
	  AND WORKCENTERCODE = @WORKCENTERCODE
	  AND ORDERNO        = @ORDERNO

	-- 가동 비가동 이력에 생산 정보 등록
	UPDATE TP_WorkcenterStatusRec
	   SET PRODQTY       = ISNULL(PRODQTY,0) + @PRODQTY
	      ,BADQTY        = ISNULL(BADQTY,0)  + @ERRORQTY
		  ,EDITOR        = @LS_WORKER
		  ,EDITDATE      = @LD_NOWDATE
	WHERE PLANTCODE      = @PLANTCODE
	  AND WORKCENTERCODE = @WORKCENTERCODE
	  AND ORDERNO        = @ORDERNO
	  AND RSSEQ		     = (SELECT MAX(RSSEQ)
							  FROM TP_WorkcenterStatusRec WITH(NOLOCK)
							 WHERE PLANTCODE      = @PLANTCODE
							   AND WORKCENTERCODE = @WORKCENTERCODE
							   AND ORDERNO        = @ORDERNO)

	-- LOT TRACKING  테이블 등록
	DECLARE @LI_SEQ INT
	 SELECT @LI_SEQ = ISNULL(MAX(SEQ),0)+ 1
	   FROM TP_LotTracking WITH(NOLOCK)
	  WHERE PLANTCODE      = @PLANTCODE
	    AND WORKCENTERCODE = @WORKCENTERCODE
		AND ORDERNO        = @ORDERNO

	-- 생산 LOT 채번 
	DECLARE @LS_LOTNO VARCHAR(30)
	    SET @LS_LOTNO = 'LTFERT' 
		                + RIGHT(@ORDERNO,4) + 'X' 
		                + RIGHT('0000' + CONVERT(VARCHAR,@LI_SEQ),4)

    -- LOT TRACKING 테이블 등록
	INSERT INTO TP_LotTracking (PLANTCODE,  ORDERNO,     WORKCENTERCODE,   SEQ,
								LOTNO,      ITEMCODE,    PRODQTY,          UNITCODE,
								CLOTNO,     CITEMCODE,   INQTY,            CUNITCODE)
						VALUES (@PLANTCODE,	@ORDERNO,    @WORKCENTERCODE,  @LI_SEQ,
								@LS_LOTNO,  @ITEMCODE,   @PRODQTY,         @UNITCODE,
								@MATLOTNO,  @CITEMCODE,	 @LF_PRODQTY,      @CUNITCODE)
    

	-- 작업장 별 생산 실적 등록 TP_WorkcenterPerProd
	DECLARE @LI_PRODSEQ INT	
	 SELECT @LI_PRODSEQ = ISNULL(MAX(PRODSEQ),0) + 1
	   FROM TP_WorkcenterPerProd WITH(NOLOCK)
	  WHERE PLANTCODE      = @PLANTCODE
	    AND WORKCENTERCODE = @WORKCENTERCODE
		AND PRODDATE       = @LS_NOWDATE

	INSERT INTO TP_WorkcenterPerProd (PLANTCODE,    PRODDATE,     WORKCENTERCODE,   PRODSEQ,
									  ITEMCODE,     ORDERNO,      PRODQTY,          BADQTY,
									  TOTALQTY,     UNITCODE,     INLOTNO,          LOTNO,     
									  MAKER,        MAKEDATE)
							  VALUES (@PLANTCODE,   @LS_NOWDATE, @WORKCENTERCODE,   @LI_PRODSEQ,
									  @ITEMCODE,    @ORDERNO,    @PRODQTY,          @ERRORQTY,
									  @LF_TOTALQTY, @UNITCODE,   @MATLOTNO,         @LS_LOTNO,
									  @LS_WORKER,   @LD_NOWDATE)
    

	-- 재공 재고 차감 이력 등록
	SELECT @INOUTSEQ = ISNULL(MAX(INOUTSEQ),0) + 1
	  FROM TB_StockHALBrec WITH(NOLOCK)
	 WHERE PLANTCODE = @PLANTCODE
	   AND RECDATE   = @LS_NOWDATE

	 -- 재공 재고 차감 이력 등록
	 INSERT INTO TB_StockHALBrec (PLANTCODE,        INOUTSEQ,   RECDATE,       LOTNO,        ITEMCODE,   
	                              WORKCENTERCODE,   INOUTFLAG,  INOUTCODE,     INOUTQTY,     UNITCODE,
								  MAKEDATE,         MAKER)								   
					      VALUES (@PLANTCODE,       @INOUTSEQ,  @LS_NOWDATE,   @MATLOTNO,    @CITEMCODE,
								  @WORKCENTERCODE,	'OUT',      '40',          @LF_FINALQTY, @CUNITCODE,
								  @LD_NOWDATE,      @LS_WORKER)   
	 
	 -- 재공 재고 차감
	 IF (SELECT STOCKQTY - @LF_FINALQTY
	       FROM TB_StockHALB WITH(NOLOCK)
		  WHERE PLANTCODE = @PLANTCODE
		    AND LOTNO	  = @MATLOTNO) = 0
	 BEGIN
		DELETE TB_StockHALB 
		 WHERE PLANTCODE = @PLANTCODE
		   AND LOTNO     = @MATLOTNO

	 -- 작업장 현재 상태 UPDATE
	 UPDATE TP_WorkcenterStatus --작업지시가 종료되면 이 테이블은 삭제
	    SET INLOTNO        = NULL
		   ,COMPONENT      = NULL
		   ,COMPONENTQTY   = NULL
		   ,CUNITCODE      = NULL
		   ,EDITDATE       = @LD_NOWDATE
		   ,EDITOR         = @LS_WORKER
	  WHERE PLANTCODE      = @PLANTCODE
	    AND WORKCENTERCODE = @WORKCENTERCODE
		AND ORDERNO        = @ORDERNO

	 END
	 ELSE
	 BEGIN
		UPDATE TB_StockHALB
		   SET STOCKQTY = STOCKQTY - @LF_FINALQTY
		 WHERE PLANTCODE = @PLANTCODE
		   AND LOTNO     = @MATLOTNO
	 END


	 -- 공정 재고 등록
	 INSERT INTO TB_StockPP (PLANTCODE,    LOTNO,       ITEMCODE,    WHCODE,    
							 STOCKQTY,     MAKEDATE,    MAKER)
					 VALUES (@PLANTCODE,   @LS_LOTNO,   @ITEMCODE,   'WH003',
					         @PRODQTY,     @LD_NOWDATE, @LS_WORKER)

	 -- 공정 재고 입고 이력 등록
	 SELECT @INOUTSEQ = ISNULL(MAX(INOUTSEQ),0) + 1
	   FROM TB_StockPPrec WITH(NOLOCK)
	  WHERE PLANTCODE = @PLANTCODE
	    AND RECDATE   = @LS_NOWDATE

	 INSERT INTO TB_StockPPrec (PLANTCODE,   INOUTSEQ,    RECDATE,      LOTNO,     ITEMCODE,   WHCODE,   
							    INOUTFLAG,   INOUTCODE,   INOUTQTY,     UNITCODE,  MAKEDATE,   MAKER)
						 VALUES(@PLANTCODE,  @INOUTSEQ,   @LS_NOWDATE,	@LS_LOTNO, @ITEMCODE,  'WH003',
								'IN',        '45',        @PRODQTY,     @UNITCODE, @LD_NOWDATE, @LS_WORKER)
	 SET @RS_CODE = 'S'
END
GO
