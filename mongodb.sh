#!/bin/bash

ID=$(id -u)

R="\e[31m"
g="\e[32m"
N="\e[0m"
Y="\e[33m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e " $2 .. $R Installation failed $N"
        exit 1
    else
        echo -e " $2 ..$G success $N"
}


if [ ID -ne 0 ]
then
    echo -e "$R Run the script with root user $N"
    exit 1
else
    echo -e "$G proceed you are root user $N"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo #manually we do in vim editor,in shell we create one file repo and copy there.
VALIDATE $? "copied mongodb Repo"

yum list installed $mongodb 
if [ $? -ne 0 ]
then
     dnf install $mongodb-org -y
    VALIDATE $? "installing  $mongodb"
else
    echo -e "$mongodb already installed.. $Y SKIPPING"
fi

systemctl enable mongod
VALIDATE $? "enabled mongod"

systemctl start mongod
VALIDATE $? "mongod started"

