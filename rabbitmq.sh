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


curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE

VALIDATE $? "downloading erlang script" 

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE

VALIDATE $? "downloading rabbitmq script" 

dnf install rabbitmq-server -y  &>> $LOGFILE

VALIDATE $? "installing rabbitmq"

systemctl enable rabbitmq-server  &>> $LOGFILE

VALIDATE $? "enabling rabbitmq-server"

systemctl start rabbitmq-server &>> $LOGFILE

VALIDATE $? "starting rabbitmq-server"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE

VALIDATE $? "creating user" 

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE

VALIDATE $? "setting permissions"

