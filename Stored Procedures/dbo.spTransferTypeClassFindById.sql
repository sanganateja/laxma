SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spTransferTypeClassFindById]
    @cv_1 VARCHAR(2000) OUTPUT,
    @TransferTypeClassId BIGINT
AS
BEGIN
    SET NOCOUNT ON
    SET @cv_1 = NULL;

    SELECT TransferTypeClassId,
           ClassName
    FROM dbo.tlkpTransferTypeClass
    WHERE TransferTypeClassId = @TransferTypeClassId;

END;
GO
