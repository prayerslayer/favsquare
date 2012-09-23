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
			$.get( host + "/" + resource + "/" + amount, function( tracks ) {
				_.each( tracks, function( track ) {
					var bbtrack = new Track( track );
					var trackview = new TrackView({
						model: bbtrack
					});
					bbtrack.set( "view" , trackview );
					playlist.add( bbtrack );
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
	$( "#arrow" ).click(function() {
		Favsquare.fetch( 10 );
	});
	Favsquare.rocks();
});