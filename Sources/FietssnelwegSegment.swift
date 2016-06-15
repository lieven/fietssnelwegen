//
//  FietssnelwegSegment.swift
//  Fietssnelwegen
//
//  Created by Lieven Dekeyser on 04/06/16.
//  Copyright © 2016 Plane Tree Software. All rights reserved.
//

import MapKit

class FietssnelwegSegment : PolylineOverlay
{
	enum RealisatieGraad
	{
		case onbekend
		case onbestaand
		case bestaand
	}
	
	let realisatiegraad : RealisatieGraad
	
	init(polyline : MKPolyline, realisatiegraad : RealisatieGraad)
	{
		self.realisatiegraad = realisatiegraad
		
		super.init(polyline: polyline)
	}
}
