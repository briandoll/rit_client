rit-client
==========

rit-client is a Rails plugin that provides access to the [Rit. content scheduling system](http://github.com/briandoll/Rit/).

Please see the [Rit documentation and wiki](http://github.com/briandoll/Rit/) for more information on Rit.

Install
=======

    ./script/plugin install git://github.com/briandoll/rit_client.git

Configure
=========

    # In config/initializers/rit.rb
    RIT_HOST = 'rit.example.com'
    RIT_PORT = 8080

Basic Usage
===========

Once the plugin is installed you'll be able to access Rit. content from your controllers and views.

A safe method that returns nil if no content is found:

    rit_plate(layout_name, instance_name, plate_name)

An 'unsafe' method that may throw either a Rit::NotFoundError or a Rit::TimeoutError

    rit_plate!(layout_name, instance_name, plate_name)

Usage with Rit
==============

See the [Rit wiki](http://wiki.github.com/briandoll/Rit/) for detailed usage with Rit.


Copyright (c) 2009, 2010 Brian Doll, Kasima Tharnpipitchai, Sheet Music Plus LLC, released under the MIT license
