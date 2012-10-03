PlaylistView = Backbone.View.extend({

	initialize: function() {
		this.model.bind( "add", this.addTrack, this );
		this.render();
	},

	render: function( ) {
		$( this.el ).append("<ol id='playlist-list'></ol>");
		return this;
	},

	events: {
		"click [data-role = prev]": "previousTrack",
		"click [data-role = play]": "playTrack",
		"click [data-role = next]": "nextTrack"
	},

	currentTrack: 0,

	addTrack: function( track ) {
		var trackview = new TrackView({
			model: track,
			parent: this
		});
		$( this.el ).find( "#playlist-list" ).append( trackview.el );
	},

	previousTrack: function(  ) {
		if ( this.currentTrack - 1 >= 0 ) {
			this.pauseCurrent();
			this.currentTrack = this.currentTrack - 1;

			this.playTrack();
		}
	},
	playTrack: function( ) {
		var track = this.model.at( this.currentTrack );
		if ( !track.get( "playing" ) ) {
			track.set( "playing", true );
			track.trigger( "play" );
			$( ".play-button" ).attr( "src", "img/pause.png" );
			$( "#current-track" ).attr( "href", "#track-"+track.id );
			$( "#current-track" ).text( (this.currentTrack+1) + ". "+ track.get( "user" ).username + " - " + track.get( "title" ) );	
		}
		else {
			track.set( "playing", false );
			track.trigger( "pause" );
			$( ".play-button" ).attr( "src", "img/play.png" );
		}

	},

	setPlayingTrack: function( track ) {
		var index = _.indexOf( this.model.pluck( "id" ), track.id );
		this.currentTrack = index;
		$( "#current-track" ).attr( "href", "#track-"+track.id );
		$( "#current-track" ).text( (this.currentTrack+1) + ". "+ track.get( "user" ).username + " - " + track.get( "title" ) );	
	},

	fetchThenPlay: function( ) {
		var that = this;
		this.model.fetch({
			add: true,
			success: function( ) {
				that.playNext();
			},
			error: function( resp ) {
				console.log( resp );
				alert("nooo");
			}
		});
	},

	playNext: function( ) {
		this.currentTrack = this.currentTrack + 1;

		this.playTrack();
	},

	pauseCurrent: function( ) {
		var track = this.model.at( this.currentTrack );
		track.trigger( "pause" );
		track.set( "playing", false);
	},
	
	nextTrack: function(  ) {
		var track = this.model.at( this.currentTrack );
		if ( track == null ) {
			this.fetchThenPlay();
			return;
		}

		this.pauseCurrent();

		if ( this.currentTrack + 1 >= this.model.length ) {
			this.fetchThenPlay();
		}
		else
			this.playNext();
	}
});