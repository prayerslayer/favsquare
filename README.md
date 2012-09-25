# Favsquare

Listen to the favorite tracks of the people you follow on SoundCloud.

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
* Functionality
	* Verbindung TrackView <-> PlaylistView über Mediator
	* Von HTML5 Widgets auf eigene UI umsteigen
		* Event delegation von TrackView nach Playlist?
		* Track Template schön bekommen, mit Kommentaren, Zeitanzeige aktuell/total, Avatar
		* Navbar permanent machen, dort auch Controls rein (zumindest Anzeige)
	* "Create playlist on SC" Feature
	* Token erneuern, wenn Startseite angesurft wird
	* User-defined update
	* First-time load takes too long. Some sort of pipelining?
* Improve UI
	* "back to top" feature oder Navbar immer on top sein lassen
	* Spinner
	* Front page


# Funktionen

* DB
	* Token speichern, verschlüsselt
	* Token refreshen
	* User hinzufügen/löschen
	* Tracks des Users hinzufügen/updaten/löschen
* Frontend
	* Browsing
		* Treemap (# Tracks pro Artists, denen User nicht folgt) + Follow-Buttons?
		* Alphabetische Liste (Artists)
			* Seiten für Artists (/artist/rem)
	* Listening
		Playlist