#!/bin/bash

USERID=$(id -u) # Display UserID value, For root user its 0
R="\e[31m" # Print Red color
G="\e[32m" # Print Green color
Y="\e[33m" # Print Yellow color
N="\e[0m" # Print Default White color
LOGS_FOLDER="/var/log/Expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"


mkdir -p $LOGS_FOLDER
echo "Created the $LOGS_FOLDER directory"

CHECK_ROOT()
{
if [ $USERID -ne 0 ]
then
    echo "ERROR : User does not have SUDO access to execute this script"
    exit 1 # Other than 0
fi
}

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

echo "Started the shell script at $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT

dnf list installed mysql-server &>>$LOG_FILE_NAME

if [ $? -ne 0 ]
then
    echo "MYSQL Server is not installed..So, Installing MYSQL Server"
    dnf install mysql-server -y &>>$LOG_FILE_NAME
    VALIDATE $? "MYSQL Server Installation"
else
    echo -e "$Y MYSQL Server is already Installed $N"
fi

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Enable MYSQL Server"

systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "Starting MYSQL Server"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "Setting Root password"