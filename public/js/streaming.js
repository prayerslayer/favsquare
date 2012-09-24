$( document ).ready( function() {

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
					if ( tracks.length > 0 ) {
						var bbtracks = [];
						_.each( tracks, function( track ) {
							var bbtrack = new Track( track );
							bbtracks.push( bbtrack );	//hopefully they won't get inserted one at a time
						});
						playlist.add( bbtracks );
					}
				});
			}
		};
	})();

	SC.initialize({
		client_id: "fcdca5600531b2292ddc9bfe7008cac6"
	});
	$( "#arrow" ).click(function() {
		Favsquare.fetch( 10 );
	});
	Favsquare.rocks();
});