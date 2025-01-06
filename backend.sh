#!/bin/bash

USERID=$(id -u) # Display UserID value, For root user its 0
R="\e[31m" # Print Red color
G="\e[32m" # Print Green color
Y="\e[33m" # Print Yellow color
N="\e[0m" # Print Default White color
LOGS_FOLDER="/var/log/Expenseshelllogs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"


mkdir -p $LOGS_FOLDER
echo "Created the $LOGS_FOLDER directory"
echo "Started the shell script at $TIMESTAMP" &>>$LOG_FILE_NAME

if [ $USERID -ne 0 ]
then
    echo "ERROR : User does not have SUDO access to execute this script"
    exit 1 # Other than 0
fi


VALIDATE()
{
    if [ $1 -ne 0 ]
    then
        echo -e "$2..$R FAILURE $N"
        exit 1
    else
        echo -e "$2..$G SUCCESS $N"
    fi
}

dnf module disable nodejs -y
dnf module enable nodejs:20 -y


dnf list installed nodejs &>>$LOG_FILE_NAME

if [ $? -ne 0 ]
then
    echo "nodejs is not installed..So, Installing nodejs Server"
    dnf install nodejs -y &>>$LOG_FILE_NAME
    VALIDATE $? "nodejs"
else
    echo -e "$Y nodejs is already Installed $N"
fi

useradd expense

mkdir -p /app
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
cd /app
unzip /tmp/backend.zip
npm install
cp /home/ec2-user/ExpenseProj_Shell/backend.service /etc/systemd/system/backend.service

systemctl daemon-reload
systemctl start backend
systemctl enable backend


dnf list installed mysql &>>$LOG_FILE_NAME

if [ $? -ne 0 ]
then
    echo "mysql is not installed..So, Installing mysql Server"
    dnf install mysql -y &>>$LOG_FILE_NAME
    VALIDATE $? "mysql"
else
    echo -e "$Y mysql is already Installed $N"
fi

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pExpenseApp@1 < /app/schema/backend.sql

systemctl restart backend