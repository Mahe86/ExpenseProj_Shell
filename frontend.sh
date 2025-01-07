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

dnf module list nginx &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
    dnf install nginx -y &>>$LOG_FILE_NAME
    VALIDATE $? "Installing nginx"
else
    echo -e "$Y nginx is already Installed $N"
fi

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloading front end files"

cd /usr/share/nginx/html

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
VALIDATE $? "Deleting old files"

unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
VALIDATE $? "Unzipping front end files"

cp /home/ec2-user/ExpenseProj_Shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE_NAME
VALIDATE $? "Copying expense.conf file"

systemctl enable nginx &>>$LOG_FILE_NAME
VALIDATE $? "Enable nginx"

systemctl restart nginx
VALIDATE $? "restart nginx"