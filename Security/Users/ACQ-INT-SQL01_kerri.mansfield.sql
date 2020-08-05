IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'ACQ-INT-SQL01\kerri.mansfield')
CREATE LOGIN [ACQ-INT-SQL01\kerri.mansfield] FROM WINDOWS
GO
CREATE USER [ACQ-INT-SQL01\kerri.mansfield] FOR LOGIN [ACQ-INT-SQL01\kerri.mansfield]
GO
