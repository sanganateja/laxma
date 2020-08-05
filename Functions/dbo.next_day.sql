SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create   FUNCTION [dbo].[next_day](@date_t as datetime, @weekday nvarchar(40))
returns datetime
begin
  declare @retval datetime, @Deltaday integer, @dayNumber integer
  if isnumeric(@weekday) = 0
    begin
      select @dayNumber = dayNumber
      from (
      select dayNumber = datepart(dw, @date_t), dayName = datename(dw, @date_t)
      union all
      select datepart(dw, dateadd(day, 1, @date_t)), datename(dw, dateadd(day, 1, @date_t))
      union all
      select datepart(dw, dateadd(day, 2, @date_t)), datename(dw, dateadd(day, 2, @date_t))
      union all
      select datepart(dw, dateadd(day, 3, @date_t)), datename(dw, dateadd(day, 3, @date_t))
      union all
      select datepart(dw, dateadd(day, 4, @date_t)), datename(dw, dateadd(day, 4, @date_t))
      union all
      select datepart(dw, dateadd(day, 5, @date_t)), datename(dw, dateadd(day, 5, @date_t))
      union all
      select datepart(dw, dateadd(day, 6, @date_t)), datename(dw, dateadd(day, 6, @date_t))
      ) a
      where upper(dayName) = upper(@weekday) or left(upper(dayName), 3) = upper(@weekday)

      set @dayNumber = isnull(@dayNumber, 0) 
    end
  else set @dayNumber = @weekday

  if not (@dayNumber between 1 and 7)
    begin      
      set @retval = null
      return @retval
    end
  set @Deltaday = case when @@DateFirst <= datepart(dw, @date_t) then 7 - datepart(dw, @date_t) + @dayNumber
                       else @@DateFirst - datepart(dw, @date_t) + @dayNumber
                  end
  if @Deltaday > 7 set @Deltaday = @Deltaday - 7

  select @retval = dateadd(day, @Deltaday, @date_t)

  return @retval
end
GO
