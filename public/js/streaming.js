var Favsquare = (function() {

	var host = "http://localhost:9393",
		resource = "tracks",
		playlist = new Playlist(),
		playlistView = new PlaylistView({
			model: playlist,
			el: "#playlist"
		});
		

	return {
		//start everythings
		rocks: function() {
			this.fetch( 10 );
		},
		//fetch tracks, add to playlist
		fetch: function( amount ) {
			$.get( host + "/" + resource + "/" + amount, function( track_ids ) {
				_.each( track_ids, function( track_id ) {
					var track = new Track({ id: track_id });
					var trackview = new TrackView({
						model: track
					});
					track.set( "view" , trackview );
					playlist.add( track );
				});
				playlistView.render();
			});
		}
	};
})();

$( document ).ready( function() {
	SC.initialize({
		client_id: "fcdca5600531b2292ddc9bfe7008cac6"
	});
	Favsquare.rocks();
});