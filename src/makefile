
all: test
	# == Done == #
	
build:
	haxe-nightly build.hxml

test: build
	clear
	#
	# == Testing Python == #
	cd ../dist/python && python3 ./app.py cheeks
	#
	# == Testing NodeJS
	cd ../dist/node && nodejs ./app.js cheeks
	#
	# == Testing C++ == #
	cd ../dist/cpp && ./App-debug cheeks
	#
	# == Testing Neko == #
	cd ../dist/neko && neko ./App.n cheeks
	#
	# == Testing Java == #
	cd ../dist/java && java -jar ./App-Debug.jar cheeks
	#
	# == Testing PHP == #
	cd ../dist/php && php -f ./index.php
