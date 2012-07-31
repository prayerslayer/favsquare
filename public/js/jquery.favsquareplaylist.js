( function( $ ) {

	var settings = {};
	var playlist = [];
	var react_to_scroll = true;

	var methods = {

		init: function( options ) {

			settings = $.extend( {
				"amount": 10,
				"server_url": "http://localhost:9393",
				"server_resource": "/tracks",
				"that": $( this ),
				"css_class": "track"
			}, options);

			return this.each( function() {
				methods.fetch();
				$( window ).bind( "scroll.favsquareplaylist", methods.scroll );
			});	
		},

		scroll: function() {
			if ( $( window ).scrollTop() === $( document ).height() - $( window ).height() ) {
				if ( react_to_scroll ) {
					console.log( "INFINITY" );
					methods.fetch();
				}
			}
		},

		fetch: function() {
			react_to_scroll = false;
			$.when(
				$.get( settings.server_url + settings.server_resource + "/" + settings.amount, function( tracks ) {
					$.each( tracks, function( index, value ) {
						var track = $( "<div class='" + settings.css_class + "'>" + value + "</div>" );
						settings.that.append( track );
						var dom_tracks = document.querySelectorAll("."+settings.css_class+" iframe");
						methods.add_to_playlist( track, dom_tracks[ dom_tracks.length -1 ] );  
					});
				}))
			.done(function() {
				react_to_scroll = true;
			});
		},

		add_to_playlist: function( track, iframe ) {
			var widget = SC.Widget( iframe );
			playlist.push( {
				"track": track,
				"widget": widget
			} );
			var index = playlist.length - 1;
			widget.bind( SC.Widget.Events.PLAY, function() {

			});

			widget.bind( SC.Widget.Events.FINISH, function() {
				if ( playlist.length > index + 1 )
					playlist[ index + 1 ].widget.play();
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

	$.fn.favsquareplaylist = function( method ) {
    
		if ( methods[ method ] ) {
			return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
		} else if ( typeof method === 'object' || ! method ) {
			return methods.init.apply( this, arguments );
		} else {
			$.error( 'Method ' +  method + ' does not exist on jQuery.favsquareplaylist' );
		}    

	};

})( jQuery );