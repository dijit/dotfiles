#!/bin/sh
today=$(/bin/date +"%Y-%m-%d")
logpath="/web/01/logs/clothingattesco/"
for intg in OrderDespatch OrderReturnRefund SalesPromoExport
do for i in $(/bin/grep "Running plugin pluginName=$intg method=main" ${logpath}admin8_${today}.log | /bin/awk -F\| '{print $6}' | /bin/sort -u);
    do match=$(/bin/grep $i ${logpath}admin8_${today}.log | /bin/grep Venda::Exception::Lock | /bin/awk -F\| '{print $1" "$6}' | /usr/bin/head -n 1)
    if [ "X$match" != "X" ] 
      then /bin/echo "$match $intg"
    fi
done
done
