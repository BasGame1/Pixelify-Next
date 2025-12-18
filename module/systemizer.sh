#!/system/bin/sh

APP=$1
PRIVAPP_PATH=$2

print "Searching $APP in /data/app "
APP=($find -maxdepth 2 /data/app -name "*$APP*" -print)
if [-d $APP ]; then
    print "Found $APP in /data/app"
else 
    print "$APP not found, please run again"
    return 1
fi
print "Moving $APP to $PRIVAPP_PATH"
mv $APP $PRIVAPP_PATH   

