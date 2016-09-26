lib-sndbar
=========
An Audio Engine written in ActionScript.

`AudioPlayer` is the core part of this engine which provides support for media operations on a single audio file.

The `AudioPlayer` class exposes the following methods:

* `playSoundWithFilePath()` - Pass a valid file path and once loaded asynchronously, the audio gets played
* `stopPlayer()` - Stops the audio and resets the play position to 0
* `pausePlayer()` - Pauses the audio and saves the current play position
* `setCurrentVolume()` - Set the volume
* 'getCurrentVolume()' - Returnes the current volume

Implementation
==============
The Triton Player (https://github.com/midhunhk/triton-player) uses lib-sndbar under its hood.

License
=======
The source code for lib-sndbar is licensed under MIT license.
