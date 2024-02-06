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

dnf install python36 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "installing python"


id roboshop
if [ $? -ne 0 ]
then 
    useradd roboshop  
VALIDATE $? "Creating roboshop user"
else
    echo -e "roboshop user already exists..$Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE #-p it doesnt show error if no directory it creates if already exists it doesnt create
VALIDATE $? "Creating app directory" 

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "Downloading payment application" 

cd /app 

unzip -o /tmp/payment.zip &>> $LOGFILE # "-o" overwrite
VALIDATE $? "unzipping" 

cd /app

pip3.6 install -r requirements.txt&>> $LOGFILE
VALIDATE $? "installing dependencies" 

#use absolute path becoz payment service path exists there check with pwd
#payment service is not in app directory need to give its absolute path
cp  /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "copied payment.service" 

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "cpayment  reload" 

systemctl enable payment  &>> $LOGFILE
VALIDATE $? "enable catalogue" 

systemctl start payment  &>> $LOGFILE
VALIDATE $? "starting payment " 




