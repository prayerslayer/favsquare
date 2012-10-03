$( document ).ready( function() {
	$.get( "missing", function( data ) {

		var width = 1000,
			height = 800,
			color = d3.scale.category10();

		var force = d3.layout.force()
					.nodes( data )
					.links( [] )
					.size( [ width, height ] )
					.start();

		var svg = d3.select( "#treemap" )
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
			.selectAll( "circle" )
			.data( data )
			.enter()
				.append( "circle")
				.attr( "r", function( d ) {
					return d.count * 5;
				} )
				.attr( "fill", function( d ) {
					return color( d.count ) ;
				})
				.call( force.drag );

		var nodes = svg.selectAll( "circle" );

		nodes.on( "mouseover", function( d, index ) {
			text.text( d.artist );
			d.oldcolor = d3.select( this ).attr( "fill" );
			d3.select( this ).attr( "fill", "orange" );
		});

		nodes.on( "mouseout", function( d ) {
			d3.select( this ).attr( "fill", d.oldcolor );
		});

		force.on( "tick", function( ) {
			nodes
				.attr( "cx", function( d ) {
					return d.x;
				})
				.attr( "cy", function( d ) {
					return d.y;
				});
		});

	});
});