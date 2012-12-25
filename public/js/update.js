function setOkay( ok ) {
	if ( ok ) {
		$( "button[data-role=submit-email]" ).attr( "disabled", null );
	}
	else {
		$( "button[data-role=submit-email]" ).attr( "disabled", "disabled" );
	}
}

$( document ).ready( function() {

	$( "input#email" ).keyup( function ( evt ) {
		var text = $( this ).attr( "value" );
		var okay = text.match( /\S+@\S+/ ) != null && text.length > 0;
		setOkay( okay );
		if ( evt.which === 13 && okay ) {
			//enter
			$( "button[data-role=submit-email]" ).click();
			evt.preventDefault();
			return;
		}
		
	});

	$( "button[data-role=submit-email]" ).click( function( ) {

		$( "#spinner" ).fadeIn( 200 );
		$.post( "add_email", { "email": $("input#email").attr("value") }, function( data ) {
			$( "#add-email" ).fadeOut( 200 );
			$( "#response ").fadeIn( 200 );
		});
	});
});