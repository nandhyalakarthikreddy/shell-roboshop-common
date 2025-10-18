#!/bin/bash
source ./common.sh
check_root
dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling the default redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling the updated version"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "installing the redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c  protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connection to redis"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enable the redis"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "starting the redis"

print_total_time