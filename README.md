# Favsquare

Listen to the favorite tracks of the people you follow on SoundCloud.

# Usage

Check out the repository.

    git clone https://github.com/prayerslayer/favsquare.git

Bundle the gems.

    gem install bundle
    bundle install

Create a file local.env with your environment configuration.

Create the database
    rake db:migrate:up DATABASE_URL=<your database url>

Start web and worker process

	foreman start -e local.env

# License

Rain is released under [CC0](http://creativecommons.org/publicdomain/zero/1.0/). Do whatever you want, I don't care. Buy it, use it, break it, fix it, trash it, change it, mail, upgrade it...

# TODO

* Doppelte Tracks in Playlist zerhauen Playing Indicator
* TESTS anstatt Boilerplate COntract Checks
* Performance
* Was ist mit leeren playlists? --> Display something
* Frontpage
	* http://www.codinghorror.com/blog/2012/10/judging-websites.html
	* BigVideoJS --> Regen?
* User-defined update