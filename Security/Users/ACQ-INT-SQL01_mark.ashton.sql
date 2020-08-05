IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'ACQ-INT-SQL01\mark.ashton')
CREATE LOGIN [ACQ-INT-SQL01\mark.ashton] FROM WINDOWS
GO
CREATE USER [ACQ-INT-SQL01\mark.ashton] FOR LOGIN [ACQ-INT-SQL01\mark.ashton]
GO
