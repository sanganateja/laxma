IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'ACQ-INT-SQL01\Namitha.Suvarna')
CREATE LOGIN [ACQ-INT-SQL01\Namitha.Suvarna] FROM WINDOWS
GO
CREATE USER [ACQ-INT-SQL01\Namitha.Suvarna] FOR LOGIN [ACQ-INT-SQL01\Namitha.Suvarna]
GO
