# clientknob
A lossless audio streaming utility that connects a mastering studio with its clients via real-time audio feedback sessions.

## Getting Started

To get a ClientKnob server up and running is a rather simple process. After cloning this repo, do the following:

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

This will start a new Unicorn server at *localhost:8080*

Launch a new web browser and point it to http://localhost:8080/upload to see your Audio QC upload form!
