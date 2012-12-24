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

Run it! Start the web server

    bundle exec shotgun -O config.ru -E development

and the worker

    rake navvy:work DATABASE_URL=<your-database-url>

# TODO

* TESTS anstatt Boilerplate COntract Checks
* schlüssel über config file setzen, welches nicht git kontrolliert wird
* Functionality
	* TODO
		* Checken, wann update job zu Ende ist
		* Waveforms werden manchmal nicht angezeigt, aber nachdem Devtools aufgerufen wurden?
	* Was ist mit leeren playlists? --> Display something
	* Frontpage
		* http://www.codinghorror.com/blog/2012/10/judging-websites.html
		* BigVideoJS --> Regen?
	* User-defined update