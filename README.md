# Favsquare

Listen to the favorite tracks of the people you follow on SoundCloud.

# Usage

Check out the repository.

    git clone https://github.com/prayerslayer/favsquare.git

Bundle the gems.

    gem install bundle
    bundle install

Enter your preferred development database credentials in favsquare.rb. Then do

	cd favsquare # if you're not already there
	sequel -m db/migrations <your-database-url> # set up tables

Run it!

    bundle exec shotgun -O config.ru -E development

# TODO

* TESTS
* Functionality
	* TODO
		* Checken, wann update job zu Ende ist
		* Email senden, wenn Job zu Ende ist (optional, weils halt echt Minuten dauert)
		* Icons statt Text bei Phones
		* Waveforms werden manchmal nicht angezeigt, aber nachdem Devtools aufgerufen wurden?
	* TESTS
	* Was ist mit leeren playlists? --> Display something
	* Frontpage
		* BigVideoJS --> Regen?
	* Overview
		* Eventuell Avatare der User verwenden?
		* Mehr Informationen: Wieviele Favs und von wem
	* User-defined update
	* First-time load takes too long. Some sort of pipelining?