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

dnf install maven -y &>> $LOGFILE
VALIDATE $? "installing maven"

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

curl -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip

VALIDATE $? "Downloading shipping application" 

cd /app 

unzip -o /tmp/shipping.zip &>> $LOGFILE # "-o" overwrite
VALIDATE $? "unzipping shipping" 

cd /app

mvn clean package &>> $LOGFILE
VALIDATE $? "installing dependencies" 

mv target/shipping-1.0.jar shipping.jar
VALIDATE $? "renaming jar file" 


cp  /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "copied shipping.service" 

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading" 

systemctl enable shipping &>> $LOGFILE
VALIDATE $? "enable shipping" 

systemctl start shipping &>> $LOGFILE
VALIDATE $? "starting shipping" 


dnf install mysql -y  &>> $LOGFILE
VALIDATE $? "installing mysql"

mysql -h mysql.vasudevops.online -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>> $LOGFILE
VALIDATE $? "loading shippingdata" 

systemctl restart shipping
VALIDATE $? "restarted shipping"
