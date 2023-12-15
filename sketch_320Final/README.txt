Arduino code is designed to be run with a Adafruit Playground Express.

A stretch sensor is recommended for running this code, though other potentiometers should work as well.
-The code can also be run without any arduino connected, though function will of course be limited.


As not all materials used are ours to distribute, various asset files are missing from this public upload.
These should be replaced within the same folder as the Processing files, being:
-6 "environment" images with a transparent hole in the middle, 800x600, named "bg0.png", "bg1.png"..."bg5.png".
-6 pose silhouette images, 600x600, named "p0.png"..."p6.png" (without "p4.png"). These are respectively:
--0: Sun salutation
--1: Tree pose
--2: Warrior 1 (facing right)
--3: Warrior 2 (facing right).
--4 (not included; simply due to an oversight).
--5: Legs crossed, palms in the air, facing each other
--6: legs crossed, palms together.
-6 "startup" images to accompany the main pose images, also 600x600.
---These should be named similarly to their accompanying pose, simply with a "0" addended; ex. "p5.png" -> "p50.png".
-Two sound files; one for background music titled "bgm.mp3" and one confirmation chime, titled "goodSound.wav".



Breathing sensor values are sent from Arduino as the fourth value in serial transmissions.
-The first three are a remnant from earlier versions of the system which used an accelerometer.
-The high and low range of breath sensor readings is defined by the values rangeLow and rangeHigh in the BreathingVis class.
--Low corresponds to the value read when breath is fully expended; other way around for high.
--A recalibrate(int low, int high) function exists for the BreathingVis class to redefine these bounds during runtime, though is currently not implemented.




The following Processing libraries should be installed for this sketch; these can all be found in the Processing library manager:

Deep Vision 0.9.0 by Florian Bruggisser
https://github.com/cansik/deep-vision-processing

Video Library for Processing 4 2.2.2 by The Processing Foundation
https://processing.org/reference/libraries/video/index.html

Sound 2.3.1 by The Processing Foundation
https://processing.org/reference/libraries/sound/index.html


