# escape=`

FROM microsoft/windowsservercore
ARG BUILDNUMBER

# Manufacturer information
LABEL com.swyx.description="SwyxWare Docker Image" 
LABEL com.swyx.swyxwarebuild=${BUILDNUMBER} 

# Variables
ENV SQLSERVERINSTANCE="" SQLADMINUSER="" SQLADMINPASSWORD="" SQLIPPBXDATABASENAME="" SQLIPPBXUSER="" SQLIPPBXPASSWORD="" IPPBXADMINUSER="" IPPBXADMINPASSWORD="" VERBOSE=""

# Copy all required files
COPY files/. c:/install/
COPY files/start.ps1 c:/

# Set working directory
WORKDIR /install

# Install IpPbx Server
RUN ["msiexec.exe", "/i Setup.msi", "/qn", "/l*vx installServer.log", "ADDLOCAL=ALL REMOVE=IpPbxGate,ExchangeAccess2003"]

# Install IpPbx Powershell Module
RUN ["msiexec.exe", "/i Admin64.msi", "/qn", "/l*vx installAdmin.log", "ADDLOCAL=PowerShellModulePath,PowerShellExecutionPolicy"]

# Set working directory
WORKDIR /

# Startup script
CMD powershell c:/start.ps1 -SqlServerInstance %SQLSERVERINSTANCE% -SqlAdminUser %SQLADMINUSER% -SqlAdminPassword %SQLADMINPASSWORD% -SqlIpPbxDatabaseName %SQLIPPBXDATABASENAME% -SqlIpPbxUser %SQLIPPBXUSER% -SqlIpPbxPassword %SQLIPPBXPASSWORD% -IpPbxAdminUser %IPPBXADMINUSER% -IpPbxAdminPassword %IPPBXADMINPASSWORD% -VerboseMode %VERBOSE%

# Remove installation files and logs
RUN rmdir /S /Q C:\Install && rmdir /S /Q C:\ProgramData\Swyx\Traces && rmdir /S /Q C:\ProgramData\Swyx\MemoryDumps 

# Some data must be persisted
VOLUME C:/ProgramData/Swyx/Traces/ C:/ProgramData/Swyx/MemoryDumps/ C:/ProgramData/Swyx/CDRs/ C:/ProgramData/Swyx/Licenses/
