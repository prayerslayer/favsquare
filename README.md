# Favsquare

Favsquare lets you listen to the favorite tracks of the people you follow on SoundCloud.

# Usage

Check out the repository.

    git clone https://github.com/prayerslayer/favsquare.git

Bundle the gems.

    gem install bundle
    bundle install

Run it!

    bundle exec shotgun -O config.ru

# TODO

* Functionality
	* User-defined update
	* First-time load takes too long. Some sort of pipelining?
* Improve UI
	* Fix enumeration, highlight active track
	* Find proper design

# Implementation

Favsquare is built with the help of

* Server
	* Ruby on Rails
	* Sinatra
	* Mustache
	* Sequel
* Client
	* Twitter Bootstrap
	* jQuery