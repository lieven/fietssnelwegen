//
//  Fietssnelweg.swift
//  Fietssnelwegen
//
//  Created by Lieven Dekeyser on 04/06/16.
//  Copyright © 2016 Plane Tree Software. All rights reserved.
//

import MapKit


class Fietssnelweg
{
	let nummer : String
	let vanNaar : String
	
	let segmenten : [ FietssnelwegSegment]
	
	init(segmenten : [ FietssnelwegSegment ], nummer : String, vanNaar : String)
	{
		self.nummer = nummer
		self.vanNaar = vanNaar
		self.segmenten = segmenten
	}
}
