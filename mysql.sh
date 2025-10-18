#!/bin/bash
source ./common.sh
check_root
dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing my sql server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling mysql"

systemctl start mysqld  &>>$LOG_FILE
VALIDATE $? "starting my sql server"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "setting up root password"
print_total_time