if [ -t 1 ]; then
	 echo '. $MODPATH/vars.sh || abort' >> $MODPATH/functions.sh
	 echo '	error() { ' >> $MODPATH/functions.sh
	 echo '	 echo -e "$ESC[0;31m"' >> $MODPATH/functions.sh
	 echo '	 echo "$1"' >> $MODPATH/functions.sh
	 echo '	 echo -e "$ESC[0m"' >> $MODPATH/functions.sh
	 echo '	}' >> $MODPATH/functions.sh

	 echo '	blue() {' >> $MODPATH/functions.sh
	 echo '	 echo -e "$ESC[0;34m"' >> $MODPATH/functions.sh
	 echo '	 echo "$1"' >> $MODPATH/functions.sh
	 echo '	 echo -e "$ESC[0m"' >> $MODPATH/functions.sh
	 echo '	}' >> $MODPATH/functions.sh

	 echo '	green() {' >> $MODPATH/functions.sh
	 echo '	 echo -e "$ESC[0;32m"' >> $MODPATH/functions.sh
	 echo '	 echo "$1"' >> $MODPATH/functions.sh
	 echo '	 echo -e "$ESC[0m"' >> $MODPATH/functions.sh
	 echo '	}' >> $MODPATH/functions.sh

	 echo '	log() {' >> $MODPATH/functions.sh
	 echo '	 echo -e "$ESC[1;33m"' >> $MODPATH/functions.sh
	 echo '	 echo "$1"' >> $MODPATH/functions.sh
	 echo '	 echo -e "$ESC[0m"' >> $MODPATH/functions.sh
	 echo '	}' >> $MODPATH/functions.sh
 else
	 echo '	error() { ' >> $MODPATH/functions.sh
	 echo '	 echo "$1"' >> $MODPATH/functions.sh
	 echo '	}' >> $MODPATH/functions.sh

	 echo '	blue() {' >> $MODPATH/functions.sh
	 echo '	 echo "$1"' >> $MODPATH/functions.sh
	 echo '	}' >> $MODPATH/functions.sh

	 echo '	green() {' >> $MODPATH/functions.sh
	 echo '	 echo "$1"' >> $MODPATH/functions.sh
	 echo '	}' >> $MODPATH/functions.sh

	 echo '	log() {' >> $MODPATH/functions.sh
	 echo '	 echo "$1"' >> $MODPATH/functions.sh
	 echo '	}' >> $MODPATH/functions.sh
fi
 
