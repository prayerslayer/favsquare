$( document ).ready( function() {

	var Favsquare = (function() {

		var //host = "http://localhost:9393",
			host = "http://obscure-basin-1623.herokuapp.com",
			$spinner = $( "#playing-indicator" ),
			resource = "tracks/10",
			playlist = new Playlist({
				"host": host,
				"resource": resource
			}),
			playlistView = new PlaylistView({
				model: playlist,
				el: "#playlist"
			});
			

		return {
			//start everythings
			init: function() {
				$spinner.ajaxStart( function() {
					$(this).attr( "src", "img/spinner.gif" );
				});
				$spinner.ajaxStop( function() {
					$(this).attr( "src", "img/logo-small.png" );
				});
				playlist.fetch({
					add: true,
					success: function( ) {
						playlistView.playTrack();
					}
				});
			},
			fetch: function() {
				playlist.fetch({
					add: true
				});
			}
		};
	})();

	SC.initialize({
		client_id: "fcdca5600531b2292ddc9bfe7008cac6"
	});
	$( "#arrow" ).click(function() {
		Favsquare.fetch();
	});
	//simulate clicks in real playlist controls
	$( ".play-button" ).click( function() {
		$( "div[data-role=play]" ).trigger( "click" );
	});
	$( ".prev-button" ).click( function() {
		$( "div[data-role=prev]" ).trigger( "click" );
	});
	$( ".next-button" ).click( function() {
		$( "div[data-role=next]" ).trigger( "click" );
	});
	Favsquare.init();
});