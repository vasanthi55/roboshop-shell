#!/bin/bash
ID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started exucuting at $TIMESTAMP" &>> $LOGFILE
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .. $R failed $N"
        exit 1
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

dnf install nginx -y &>> $LOGFILE

VALIDATE $? "installing nginx"

systemctl enable nginx &>> $LOGFILE

VALIDATE $? "enabling nginx"

systemctl start nginx &>> $LOGFILE

VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE

VALIDATE $? "removing default website"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE

VALIDATE $? "downloaded we application"

cd /usr/share/nginx/html &>> $LOGFILE

VALIDATE $? "moving to nginx html directory"

unzip -o /tmp/web.zip &>> $LOGFILE

VALIDATE $? "unzipping web application"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE

VALIDATE $? "copied roboshop reverse proxy config"

systemctl restart nginx &>> $LOGFILE

VALIDATE $? "restarted nginx"
