# Favsquare

Favsquare lets you listen to the favorite tracks of the people you follow on SoundCloud.

# Usage

This application is in development and can not be used yet.

# TODO

* Problem: Array of tracks doesn't fit in cookie
	* Workaround 1: Use database to store them. Disadvantage: Has to be updated every time the user logs in.
	* Workaround 2: Use offsets and limits in querys to Soundcloud. Disadvantage: Sorting (shuffle) of array gets lost, duplicate tracks would be common.
	* Workaround 3: Global variable with tracks from all users.
* Implement database support
	* Feature: Remember when user listened to track the last time.
* Connect HTML5 Widgets with simple playlist feature.
* Improve UI (Design, Styles, Twitter Bootstrap)

# Implementation

Favsquare is built with the help of

* Ruby on Rails
* Sinatra
* Mustache