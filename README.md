# Knobless

A lightweight Sinatra app that QCs and auto-masters spoken word audio recordings. Get knobs and faders out of your life, once and for all!

## Getting Started

To get a Knobless server up and running is a rather simple process. First and foremost, ensure that you have all dependencies on your system. You'll need a modern version of the SoX utility, compiled with support for all audio formats. Ubuntu/Debian users should run `apt-get install sox libsoxfmt-all` if they're unsure.

Once you've acquired SoX and all accompanying tools/libraries, clone the repo. After cloning the repo, navigate to the project directory's top layer and do the following:

```
bundle install --path .bundle
```

This will install all necessary gems. If you have issues installing the gems, you may need some development tools and libraries. Debian/Ubuntu users should be able to resolve any issues by running `apt-get install ruby-dev`. Arch users can run `pacman -S base-devel`, making sure to select the *ALL* option if prompted to do so.

```
bundle exec unicorn
I, [2015-08-08T15:42:22.823660 #30242]  INFO -- : listening on addr=0.0.0.0:8080 fd=9
I, [2015-08-08T15:42:22.823752 #30242]  INFO -- : worker=0 spawning...
I, [2015-08-08T15:42:22.824287 #30242]  INFO -- : master process ready
I, [2015-08-08T15:42:22.824571 #30245]  INFO -- : worker=0 spawned pid=30245
I, [2015-08-08T15:42:22.824669 #30245]  INFO -- : Refreshing Gem list
I, [2015-08-08T15:42:22.865683 #30245]  INFO -- : worker=0 ready
```

This will start a new Unicorn server at `0.0.0.0:8080`. Launch a new web browser and point it to `0.0.0.0:8080/upload` to see your audio upload form!

## Usage

Simply select one or more audio files and click upload.

When the process is complete, a new page will appear with a QC report and an option to auto-master the file.

### Format Recommendations

* Try to always upload uncompressed audio. WAV is strongly encouraged when possible - FLAC is probably fine, too. Avoid MP3s!

* Upload mono audio whenever possible. Stereo really isn't necessary for most spoken word audio productions. If you are one of the few that requires stereo, just know that there is a slightly higher chance of processing failure.

## Todo

* Setup a database - probably Mongo

* Implement a logger - in progress

* Make the interface not look so unbelievably shitty

