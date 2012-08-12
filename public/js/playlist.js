var Favsquare = ( function() {
	var	amount = 10,
		server_url = "http://localhost:9393",
		server_res = "/tracks",
		that = null, //not yet known
		css_class = "track",
		playlist = [],
		queue = [],
		cur_index = 0;


	var pauseAll = function() {
		alert( "implement pauseAll" );
	}

	// show track, load sc widget
	var show = function( track ) {
		var dfd = jQuery.Deferred();
		that.append( track.track );
		track.track
			.hide()
			.children("iframe")
			.first()
			.load( function() {
				track.track.show( 200, function() {
					playlist.push( track );
					track.index = playlist.length - 1;
					var sc_widget = SC.Widget( document.querySelectorAll( "." + css_class + " iframe" )[ track.index ] );
					track.widget = sc_widget;
					dfd.resolve();	
				});
				
			});

		return dfd.promise();
	};

	// show track and bind events
	var dequeue = function() {
		if ( queue.length === 0 )
			return;

		var track = queue.shift();
		$.when(
			show( track )
		).then( function() {
			// auto-play first track
			// TODO gets called multiple times, probably
			if ( cur_index === 0 )
				playlist[ 0 ].widget.play();

			// bind on PLAY event
			track.widget.bind( SC.Widget.Events.PLAY, function() {
				cur_index = track.index;
			});

			//bind on FINISH event
			track.widget.bind( SC.Widget.Events.FINISH, function() {
				if ( playlist.length > cur_index + 1 )
					playlist[ cur_index + 1 ].widget.play();
				else {
					// no more tracks, need to fetch
					fetch();
				}
			});

			// add next track
			dequeue();
		});
	};

	return {
		setPlaylistElement: function( selector ) {
			that = $( selector );
			return this;
		},

		fetch: function() {
			$.get( server_url + server_res + "/" + amount, function( tracks ) {
				$.each( tracks, function( index, value ) {
					var track = $( "<div class='" + css_class + "'><div class='enumeration'>" + (playlist.length + index + 1) + "</div>' "+ value + "</div>" );
					queue.push({
						"track": track, 
						"widget": value
					});	
				});
				dequeue();
			});
		}

	};
}());

$( document ).ready( function() {
	Favsquare.setPlaylistElement( "#playlist" ).fetch();
	$( "#arrow" ).click( function() {
		Favsquare.fetch();
	});
});