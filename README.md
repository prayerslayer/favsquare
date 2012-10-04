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
	* Von HTML5 Widgets auf eigene UI umsteigen
		* spinner, wenn geladen wird
	* Overview
		* Eventuell Avatare der User verwenden?
		* Mehr Informationen: Wieviele Favs und von wem
	* Token erneuern, wenn Startseite angesurft wird, Auth-Errors erkennen
	* User-defined update
	* First-time load takes too long. Some sort of pipelining?