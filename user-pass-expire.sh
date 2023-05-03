#!/bin/bash
#create file to store username and password exp date
touch /tmp/user-expire.txt
#iterate through users since we are only looking at ec2-user now we specify ec2-user
for usern in ec2-user
do
#get this years date in seconds
today=$(date +%s)
#grab the password expire date for the user
userexpiredate=$(chage -l $usern | grep 'Password expires' |cut -d: -f2)
# get the date the password expires in seconds
passexp=$(date -d "$userexpiredate" "+%s")
#calculate the difference
exp=`expr \( $passexp - $today \)`
#get the number of days 86400 = seconds in day
expday=`expr \( $exp / 86400 \)`
#echo user namd and pass exp date to txt file
echo "$usern | $expday" > /tmp/user-expire.txt
done
#determine if the expire date is less than or equal to 10 days
if [ $expday -le 10 ]
then
	#send notification etc echo statement below is for testing.
	echo $expday
else
    echo "Password does not expire within 10 days"
fi
