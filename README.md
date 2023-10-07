> # Pre-Release

You've found DbaLight early, really early. The core structure of the module is created, but still working out a few more things such as adding commands and getting the build process in a good state for automating the releases. I'm working on this project as time permits with family and work.

[![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/wsmelton)

> If you feel that this project would benefit you or your team please consider sponsoring

# dbalight

🔦 into your SQL Server to find, test, troubleshoot or report on your environment

## Module Builder

This project utilizes [PoshCode/ModuleBuilder](https://github.com/poshcode/modulebuilder) for automation purpose in building and releasing the module.

## Installation

```posh
Install-Module dbalight -PSRepository PSGallery

# or using new PSResource module
Install-PSResource dbalight -Repository PSGallery
```

## Using dbalight

WIP (when I get some commands added will expand this one)

## Limitations

Policy right up front with this module is you will only find `Get` commands. It is for "finding" and "changing". Will you be able to make "changes" to objects in SQL Server with this module, yes. How? The module implements SQL Server Management Objects (SMO) for all the commands in the module, by nature of SMO you will inherit the ability to call the methods of those classes used. i.e., A Get command for a table will output the [Microsoft.SqlServer.Management.Smo.Table](https://learn.microsoft.com/en-us/dotnet/api/microsoft.sqlserver.management.smo.table?view=sql-smo-160#methods) class that includes all the provided methods, such as `Alter()`.

So while the limitation is this module will only have `Get` verb commands it does not mean you are only limited to "reading". The module in no way will prevent you from using native functionality in the SMO class objects or restrict permissions against any given SQL Server (you control that not me).

## History

I've been maintainer for [dataplat/dbatools](https://github.com/dataplat/dbatools) since 2016. In working on that module and helping teams implement a solution using that module I found there are scenarios that the module is too much. In some areas of work you want tooling to be fitting for the job at hand. Dbatools is meant to be full enterprise ready management tool for all (if not most) aspects of managing SQL Server. In cases though where you may only need to report or find things out in your SQL Server instances in an environment, dbatools can be a bit heavy. (I mean it does have over 600+ functions available now 🧐)

I thought of dbalight module as being something that is lightweight and can be used for those one-off times you just need to find out what is going on or in a given SQL Server environment. Whether you want to just have an automated process that reports on things happening, or you need a task in your CI/CD process to validate configurations.