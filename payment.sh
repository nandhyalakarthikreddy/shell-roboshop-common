#!/bin/bash
source ./common.sh
app_name=payment
check_root
app_setup
dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "Installing maven"
pip3 install -r requirements.txt &>>$LOG_FILE
systemd_setup
app_restart
print_total_time



