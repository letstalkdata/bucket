yum -y install sudo 
curl -o /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/rhel/7/mssql-server-2019.repo 
curl -o /etc/yum.repos.d/msprod.repo https://packages.microsoft.com/config/rhel/7/prod.repo 
yum makecache 
sudo ACCEPT_EULA=Y yum install -y mssql-tools unixODBC-devel 
yum install -y mssql-server 
echo 'export PATH=$PATH:/opt/mssql/bin:/opt/mssql-tools/bin' | sudo tee /etc/profile.d/mssql.sh 
source /etc/profile.d/mssql.sh 