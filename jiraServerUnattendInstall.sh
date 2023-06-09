#!/bin/bash

# Update system packages
yum -y update

# Download PostgreSQL 11 packages
wget https://download.postgresql.org/pub/repos/yum/11/redhat/rhel-7-x86_64/postgresql11-libs-11.15-1PGDG.rhel7.x86_64.rpm
wget https://download.postgresql.org/pub/repos/yum/11/redhat/rhel-7-x86_64/postgresql11-11.15-1PGDG.rhel7.x86_64.rpm
wget https://download.postgresql.org/pub/repos/yum/11/redhat/rhel-7-x86_64/postgresql11-server-11.15-1PGDG.rhel7.x86_64.rpm

# Install PostgreSQL 11 packages
yum -y install postgresql11-libs-11.15-1PGDG.rhel7.x86_64.rpm
yum -y install postgresql11-11.15-1PGDG.rhel7.x86_64.rpm
yum -y install postgresql11-server-11.15-1PGDG.rhel7.x86_64.rpm



/usr/pgsql-11/bin/postgresql-11-setup initdb
systemctl start postgresql-11
systemctl enable postgresql-11

# Create Jira database and user
sudo -u postgres psql -c "CREATE DATABASE jira_db WITH ENCODING 'UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0;"
sudo -u postgres psql -c "CREATE USER jira_user WITH PASSWORD 'jira_password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE jira_db TO jira_user;"

# Download and install Jira Server 8.13.11
wget https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-8.13.11-x64.bin
chmod +x atlassian-jira-software-8.13.11-x64.bin

# Create response file
cat <<EOF > response.varfile
# Jira Installation Configuration
app.install.service$Boolean=true
app.install.service$UNIX_USER=jira
app.install.service$HOME=/opt/jira
database.type=postgresql
database.hostname=localhost
database.port=5432
database.name=jira_db
database.schema=public
database.username=jira_user
database.password=jira_password
jira.home=http://localhost:8080
setup.admin.username=admin
setup.admin.password=admin_password
setup.displayName=Jira Administrator
setup.email=admin@example.com
jira.http.connector=jetty9
EOF

# Run Jira Server installation
./atlassian-jira-software-8.13.11-x64.bin -q -varfile response.varfile
