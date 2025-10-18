#!/bin/bash

source ./common.sh
app_name=catalogue
check_root
app_setup
Nodejs
systemd_setup
cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo 
VALIDATE $? "Adding mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "installing the mongodb"

mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
VALIDATE $? "load catalogue products"

app_restart
print_total_time