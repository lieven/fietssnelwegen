//
//  PolylineOverlay.swift
//  Fietssnelwegen
//
//  Created by Lieven Dekeyser on 04/06/16.
//  Copyright © 2016 Plane Tree Software. All rights reserved.
//

import MapKit


class PolylineOverlay : NSObject, MKOverlay
{
	init(polyline : MKPolyline)
	{
		self.polyline = polyline
	}
	
    @objc var coordinate: CLLocationCoordinate2D
	{
		get
		{
			return self.polyline.coordinate
		}
	}
	
    @objc var boundingMapRect: MKMapRect
	{
		get
		{
			return self.polyline.boundingMapRect
		}
	}
    
	func intersects(_ mapRect: MKMapRect) -> Bool
	{
		return self.polyline.intersects(mapRect)
	}
	
	let polyline : MKPolyline
}
