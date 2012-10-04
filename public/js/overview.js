function count_favs( data ) {
	var sum = 0;
	$.each( data, function( artistcount, index ) {
		sum += artistcount.count;
	});
	return sum;
}

$( document ).ready( function() {
	$.get( "missing", function( data ) {
		$( "#spinner" ).hide( 200 );
		$( "#message" ).show( 200 );

		var json = {
			"children": data
		};

		var width = 1000,
			height = 800,
			color = d3.scale.category10();

		var bubble = d3.layout.pack()
					.size( [ width, height ] )
					.value( function( d ) {
						return d.count
					})
					.sort( null);

		var svg = d3.select( "#graph" )
					.append( "svg" )
					.style( "position", "relative" )
					.style( "width", width+"px" )
					.style( "height", height+"px");

		var text = svg
						.append( "text" )
						.attr( "font-size", "24px" )
						.attr( "text-anchor", "middle" )
						.attr( "width", width+"px")
						.attr( "x", width/2 )
						.attr( "y", "24px" );


		svg
			.selectAll( "g" )
			.data( bubble.nodes( json ) )
			.enter()
				.append( "g")
				.attr( "transform", function( d ) {
					return "translate("+d.x+","+d.y+")";
				})
				.append( "circle" )
					.attr( "r", function( d ) {
						console.log(d);
						return d.count * 5;
					} )
					.attr( "fill", function( d ) {
						return color( d.count ) ;
					});

		var nodes = svg.selectAll( "g" );

		nodes.append( "text" )
			.attr( "text-anchor", "middle")
			.attr( "dy", "-.5em")
			.text( function( d) {
				if ( d.artist )
					return d.artist.substring( 0, d.r/3);
				return "";
			});

		nodes.on( "mouseover", function( d, index ) {
			text.text( d.artist );
			d3.select( this ).attr( "cursor", "pointer" );
			d.oldcolor = d3.select( this ).select( "circle" ).attr( "fill" );
			d3.select( this ).select( "circle" ).attr( "fill", "#312783" );
		});

		nodes.on( "click", function( d ) {
			window.open( "http://soundcloud.com/"+d.artist, "_blank" );
		});

		nodes.on( "mouseout", function( d ) {
			d3.select( this ).select( "circle" ).attr( "fill", d.oldcolor );
		});

	});
});