$(document).ready( function() {
	var server_url = "http://localhost:9393";

	$.get( server_url+"/tracks/10", function( tracks ) {
		console.log( tracks );
		$.each( tracks, function( index, value ) {
			if ( value != null && value.length > 0) {
				track = $("<div class='track'>"+value+"</div>");
				console.log( track );
				$( "#playlist" ).append( track );
			}
		});
	});
});