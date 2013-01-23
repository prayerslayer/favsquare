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
    rake db:migrate:up DATABASE_URL=< your database url >

Start web and worker process

	foreman start -e local.env

# License

Rain is released under [CC0](http://creativecommons.org/publicdomain/zero/1.0/). Do whatever you want, I don't care. Buy it, use it, break it, fix it, trash it, change it, mail, upgrade it...

# TODO

* Eigenes Navbar Template für Playliste
* onsuspend() event für Sounds, wenn Gerät in Standby geht
* TESTS anstatt Boilerplate COntract Checks
* Was ist mit leeren playlists? --> Display something