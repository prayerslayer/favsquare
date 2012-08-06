( function( $ ) {

	

	$.fn.favsquareplaylist = function( options ) {

		var settings = $.extend( {
			"amount": 10,
			"server_url": "http://localhost:9393",
			"server_resource": "/tracks",
			"that": $( this ),
			"css_class": "track"
		}, options);

		var playlist = [];
		var react_to_scroll = true;
		var current_index = 0;

		var methods = {

			scroll: function() {
				if ( $( window ).scrollTop() === $( document ).height() - $( window ).height() ) {
					if ( react_to_scroll ) {
						console.log( "INFINITY" );
						methods.fetch();
					}
				}
			},

			pauseAll: function() {
				for (var i = playlist.length - 1; i >= 0; i--) {
					playlist[ i ].widget.pause();
					var enumeration = playlist[ i ].track.children( ".enumeration" );
					if ( enumeration.css( "color" ) === "orange" )
						enumeration.css( "color", "grey" );
				};
			},

			//loads $amount many tracks from the server
			fetch: function() {
				react_to_scroll = false;
				settings.that.spin();
				$.when(
					$.get( settings.server_url + settings.server_resource + "/" + settings.amount, function( tracks ) {
						$.each( tracks, function( index, value ) {
							var track = $( "<div class='" + settings.css_class + "'><h1 class='enumeration visible-desktop'></h1>" + value + "</div>" );
							settings.that.append( track );
							var dom_tracks = document.querySelectorAll("."+settings.css_class+" iframe");
							methods.add_to_playlist( track, dom_tracks[ dom_tracks.length -1 ] );  
						});
					}))
				.done(function() {
					react_to_scroll = true;
					settings.that.spin(false);
				});
			},

			add_to_playlist: function( track, iframe ) {
				var widget = SC.Widget( iframe );
				playlist.push( {
					"track": track,
					"widget": widget
				} );
				var enumeration = track.children( ".enumeration" );
				var index = playlist.length - 1;
				enumeration.text( ( index + 1 ) + "." );
				enumeration.on( "click", function() {
					methods.pauseAll();
					widget.play();
				});
				widget.bind( SC.Widget.Events.PLAY, function() {
					current_index = index;
					enumeration.css("color", "orange");
				});

				widget.bind( SC.Widget.Events.FINISH, function() {
					enumeration.css("color", "grey");
					if ( playlist.length > current_index + 1 )
						playlist[ current_index + 1 ].widget.play();
					else {
						methods.fetch();
						// play first of new tracks
						var count = playlist.length; // e.g. 30, we want to play the 21.
						playlist[ count - ( settings.amount - 1 )].widget.bind( SC.Widget.Events.READY, function() {
							playlist[ count - ( settings.amount - 1 )].widget.play();
						});
					}
				});
				//auto-play the first one
				if ( index === 0 ) {
					widget.bind( SC.Widget.Events.READY,  function() {
						widget.play();
					});
				}

				
			}
		};

		return this.each( function() {
			methods.fetch();
			$( window ).bind( "scroll.favsquareplaylist", methods.scroll );
		})

	};

})( jQuery );