#!/bin/bash
#
sudo ACCEPT_EULA='Y' MSSQL_LCID=1033 MSSQL_PID='Developer' MSSQL_SA_PASSWORD='Bucket1@mssql' MSSQL_TCP_PORT=1433 /opt/mssql/bin/mssql-conf setup 
systemctl enable mssql-server 
systemctl status mssql-server 
