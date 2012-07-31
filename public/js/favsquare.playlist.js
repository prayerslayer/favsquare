$(document).ready( function() {
	var server_url = "http://localhost:9393";

	var fetch_tracks = function(amount) {
		$.get( server_url+"/tracks/"+amount, function( tracks ) {
			console.log( tracks );
			$.each( tracks, function( index, value ) {
				if ( value != null && value.length > 0) {
					track = $("<div class='track'>"+value+"</div>");
					console.log( track );
					$( "#playlist" ).append( track );
				}
			});
		});
	};

	$( window ).scroll( function() {
		if ( $( window ).scrollTop() === $( document ).height() - $( window ).height() ) {
			console.log( "INFINITY" );
			fetch_tracks( 10 );
		}
	});

});