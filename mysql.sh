#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
 # no need to give evrytime while validating if we give here it goes to logs error or success.

echo "Script started exucuting at $TIMESTAMP" &>> $LOGFILE

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

dnf module disable mysql -y &>> $LOGFILE

VALIDATE $? "Disbale current mysql server"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE


VALIDATE $? "copied mysql repo" 


dnf install mysql-community-server -y &>> $LOGFILE


VALIDATE $? "installing mysql server"

systemctl enable mysqld &>> $LOGFILE


VALIDATE $? "enabling mysql"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? "Setting MYSQL root password"

mysql -uroot -pRoboShop@1 &>> $LOGFILE

VALIDATE $? "checking password"