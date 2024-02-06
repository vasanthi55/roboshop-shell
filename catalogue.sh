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
        echo -e "$2 .. $R failed $N"
        
    else
        echo -e "$2 .. $G success $N"
    
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

mkdir /app &>> $LOGFILE
VALIDATE $? "Creating app directory" 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "Downloading catalogue application" 

cd /app 
unzip /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "unzipping" 

cd /app
npm install &>> $LOGFILE
VALIDATE $? "installing dependencies" 

#use absolute path becoz catalogue service path exists there check with pwd
#catalogue service is not in app directory need to give its absolute path
cp  /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "copied catalogue.service" 

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reload" 

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "enable catalogue" 

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "starting catalogue" 

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copied mongo repo" 

dnf install mongodb-org-shell -y  &>> $LOGFILE
VALIDATE $? "installing mongodb client"

mongo --host mongodb.vasudevops.online </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "loading catalogue data" 





