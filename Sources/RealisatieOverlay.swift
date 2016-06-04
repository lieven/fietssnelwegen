//
//  Realisatiegraad.swift
//  Fietssnelwegen
//
//  Created by Lieven Dekeyser on 04/06/16.
//  Copyright © 2016 Plane Tree Software. All rights reserved.
//

import MapKit

class RealisatieOverlay : PolylineOverlay
{
	let gerealiseerd : Bool
	
	init(polyline : MKPolyline, gerealiseerd : Bool)
	{
		self.gerealiseerd = gerealiseerd
		
		super.init(polyline: polyline)
	}
}
