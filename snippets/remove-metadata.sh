#!/usr/bin/env bash
# <kuchen@kekse.biz>
#
# TODO # (recursively remove any metadata for publishing photos in the web..)
#

	# installation `exiftool`:

		# `apt install libimage-exiftool-perl`

	# anzeigen

		# `exiftool image.jpg` # alle metadaten

		# `exiftool -l image.jpg` # alle im langformat

	# aendern

		# `exiftool -Artist="John Doe" image.jpg`

		# `exiftool -AllDates="2023:06:11 14:30:00" image.jpg`

	# loeschen

		# `exiftool -all= image.jpg` # entfernt ALLE

