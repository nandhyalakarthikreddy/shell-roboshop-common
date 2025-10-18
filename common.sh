#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USERID=$(id -u)

LOG_FOLDER="/var/log/shell-roboshop"
FILE_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOG_FOLDER/$FILE_NAME.log"
START_TIME=$(date +%s)
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.nkrdev.space
mkdir -p $LOG_FOLDER

echo "script started and executed at :  $(date)" | tee -a $LOG_FILE

check_root(){
    if [ $USERID -ne 0 ]; then
        echo -e " $R Error :: please run the script by using root user $N "
        exit 1
    fi
}
VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$R Error :: Failed to $2 server $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$G $2 server $N" | tee -a $LOG_FILE
    fi
}

Nodejs(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disable nodejs"
    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enable nodejs"
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing nodejs"

    npm install  &>>$LOG_FILE
    VALIDATE $? "installing the library"
}

app_setup(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system cart" roboshop &>>$LOG_FILE
        VALIDATE $? "Addding system cart"
    else
        echo -e "Already exists $Y skipping $N"
    fi
    mkdir -p /app 
    VALIDATE $? "creating app directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "downloading $app_name application"

    cd /app 
    VALIDATE $? "changing to app directory"

    rm -rf /app/*
    VALIDATE $? "removing exissting code"

    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "unzip the file"
}

java_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Installing maven"
    mvn clean package &>>$LOG_FILE
    VALIDATE $? "clean package"
    mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
    VALIDATE $? "Renaming the articaft"
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service 
    VALIDATE $? "Adding $app_name repo"

    systemctl daemon-reload
    VALIDATE $? "Reload the file"

    systemctl enable $app_name &>>$LOG_FILE
    VALIDATE $? "enable the $app_name"
}
app_restart(){
    systemctl restart $app_name
    VALIDATE $? "Restarting $app_name"
}
print_total_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME-$START_TIME))
    echo -e "script executed in :: $Y $TOTAL_TIME seconds $N"
    }