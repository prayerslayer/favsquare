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

* TESTS
* Code Style
	* jQuery Plugin auseinandernehmen
* Functionality
	* Sound hakt immer noch beim laden --> 30 % der Rechenzeit = Garbage Collection
	* Token erneuern, wenn Startseite angesurft wird
	* User-defined update
	* First-time load takes too long. Some sort of pipelining?
* Improve UI
	* "back to top" feature oder Navbar immer on top sein lassen
	* Fix spinner --> unten hin
	* Find proper design for index page --> picture only?

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