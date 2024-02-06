#!bin/bash

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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "disabling  current NodeJs"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "Enabling  NodeJs"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing Nodejs:18"

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

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip
VALIDATE $? "Downloading user application" 

cd /app 

unzip -o /tmp/cart.zip &>> $LOGFILE # "-o" overwrite
VALIDATE $? "unzipping user" 

cd /app

npm install &>> $LOGFILE
VALIDATE $? "installing dependencies" 

cp  /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE $? "copied cart.service" 

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading" 

systemctl enable cart &>> $LOGFILE
VALIDATE $? "enable cart" 

systemctl start cart &>> $LOGFILE
VALIDATE $? "started cart" 
