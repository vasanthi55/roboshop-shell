#!/bin/bash
ID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"


VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .. $R installion failed $N"
        exit 1
    else
        echo -e "$2 .. $G installation success $N"
    
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R Run the script with root user $N"
    exit 1
else
    echo -e "$G proceed you are root user $N"
fi

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "disabling  current NodeJs"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "Enabling  NodeJs"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing Nodejs:18"

useradd roboshop  &>> $LOGFILE
VALIDATE $? "Creating roboshop user"

mkdir /app
VALIDATE $? "Creating app directory" &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE $? "Downloading catalogue application" &>> $LOGFILE

cd /app 
unzip /tmp/catalogue.zip
VALIDATE $? "unzipping" &>> $LOGFILE

cd /app
npm install 
VALIDATE $? "installing dependencies" &>> $LOGFILE





