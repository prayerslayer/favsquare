$( document ).ready( function() {
	$( "input[type=submit]" ).click( function() {
		$( this ).attr("disabled", "true");
		$( "p#response" ).text( "Doin' work...");
		var name = $( "input#set_name" ).attr( "value" );
		$.post( "create", {"set_name": name }, function( response, bla, blub ) {
			console.log( response, bla, blub );
		})
		.success( function() {
			$( "p#response" ).text( "Yay! Everything went alright.");
		})
		.error( function() {
			$( "p#response" ).text( "Oh no! Something went wrong...");
		});
	});
});