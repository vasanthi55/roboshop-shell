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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE #manually we do in vim editor,in shell we create one file repo and copy there.
VALIDATE $? " $G copied mongodb Repo $N"

for $mongodb
do
yum list installed $mongodb &>> $LOGFILE
if [ $? -ne 0 ]
then
     dnf install mongodb-org -y &>> $LOGFILE
    VALIDATE $? "installing  $mongodb"
else
    echo -e "$mongodb already installed.. $Y SKIPPING"
fi
done

systemctl enable mongod &>> $LOGFILE
VALIDATE $? " $G enabled mongod $N"

systemctl start mongod &>> $LOGFILE
VALIDATE $? " $G mongod started $N"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "Remote access to mongodb"
#script cant open files to edit manually we use vim editor here we user SED editor
#STREAMLINE editor--> '-i'=permanent changes, '-e'=temporary changes

systemctl restart mongod &>> $LOGFILE
VALIDATE $? " $G restarted mongodb $N"

