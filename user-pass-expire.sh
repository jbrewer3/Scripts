#!/bin/bash
#create file to store username and password exp date
touch /tmp/user-expire.txt
#iterate through users since we are only looking at ec2-user now we specify ec2-user

check_pass_exp()
{
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
        if [ $expday -le 5 ]
        then
                #send notification etc echo statement below is for testing.
                generate_password
        else
                echo "your password expires in $expday days"
                exit 0
        fi
}



generate_password()
{
        #get all nums lower and uppercase characters
        digits=({2..9})
        lower=({a..k} {m..n} {p..z})
        upper=({A..N} {P..Z})
        #cat them
        CharArray=(${digits[*]} ${lower[*]} ${upper[*]})
        #generate a random number from len of array above
        ArrayLength=${#CharArray[*]}
        password=""
        len=14
        for i in `seq 1 $len`
        do
        index=$(($RANDOM%$ArrayLength))
        char=${CharArray[$index]}
        password=${password}${char}
        done
        #change the password
        sudo sh -c 'echo ec2-user:'$password' | chpasswd'
        #push password to aws secrets manager
        secret_name="ec2-user-password-"$(date +%Y%m%d)"-"$(uname -n)""
        aws secretsmanager create-secret --name $secret_name --description "Automatically rotated secret for EC2 user password" --secret-string $password
}

check_pass_exp
