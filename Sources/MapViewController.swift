//
//  ViewController.swift
//  Fietssnelwegen
//
//  Created by Lieven Dekeyser on 03/06/16.
//  Copyright © 2016 Plane Tree Software. All rights reserved.
//

import UIKit
import MapKit


class MapViewController : UIViewController
{
	var mapView : MKMapView?
		
	init()
	{
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		let mapView = MKMapView(frame: self.view.bounds)
		mapView.autoresizingMask = [ .FlexibleWidth, .FlexibleHeight ]
		mapView.delegate = self
		mapView.mapType = .Standard
		
		self.view.addSubview(mapView)
		
		self.mapView = mapView
		
		loadPaths()
	}
	
	
	func loadPaths()
	{
		var fietssnelwegen : [ Fietssnelweg ] = []
		
		if let path = NSBundle.mainBundle().pathForResource("fietssnelwegen", ofType: "json"),
			data = NSData(contentsOfFile: path)
		{
			let jsonObject : NSDictionary!
			
			do
			{
				jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary
			}
			catch
			{
				return
			}
			
						
			if let features = jsonObject["features"] as? [ NSDictionary ]
			{
				for feature in features
				{
					if let attributes = feature["attributes"] as? [ NSString : AnyObject ],
						nummer = attributes["nummering"] as? String,
						vanNaar = attributes["van_naar"] as? String,
						lengte = attributes["lengte_km"] as? NSNumber,
						gerealiseerd = attributes["gerealisee"] as? NSNumber,
						geometry = feature["geometry"] as? NSDictionary,
						paths = geometry["paths"] as? [ NSArray ]
					{
						var segmenten : [ FietssnelwegSegment ] = []
						
						for pathArray in paths
						{
							if let polyline = pathArrayToPolyline(pathArray)
							{
								let realisatiegraad : FietssnelwegSegment.RealisatieGraad
								
								if (gerealiseerd.doubleValue == 0.0)
								{
									realisatiegraad = .Onbestaand
								}
								else if (gerealiseerd.doubleValue == lengte.doubleValue)
								{
									realisatiegraad = .Bestaand
								}
								else
								{
									realisatiegraad = .Onbekend
								}
								
								
								segmenten.append(FietssnelwegSegment(polyline: polyline, realisatiegraad: realisatiegraad))
							}
						}
						
						if (segmenten.count > 0)
						{
							fietssnelwegen.append(Fietssnelweg(segmenten : segmenten, nummer : nummer, vanNaar : vanNaar))
						}
					}
				}
			}
		}
		
		if let mapView = self.mapView
		{
			mapView.removeOverlays(mapView.overlays)
						
			for fietssnelweg in fietssnelwegen
			{
				mapView.addOverlays(fietssnelweg.segmenten, level: .AboveRoads)
				
			}
		}
	}
	
	func pathArrayToPolyline(inPathArray : NSArray) -> MKPolyline?
	{
		var coordinates : [ CLLocationCoordinate2D ] = []
		
		for coordinateArray in inPathArray
		{
			if let coordinate = coordinateArray as? [ NSNumber ]
			{
				let longitude = coordinate[0]
				let latitude = coordinate[1]
				
				coordinates.append(CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue))
			}
		}
		
		if coordinates.count > 1
		{
			return MKPolyline(coordinates: &coordinates, count: coordinates.count)
		}
		else
		{
			return nil
		}
	}
}

extension MapViewController : MKMapViewDelegate
{
	func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer
	{
		if let segment = overlay as? FietssnelwegSegment
		{
			let renderer = MKPolylineRenderer(polyline: segment.polyline)
			renderer.lineWidth = 4.0
			
			switch (segment.realisatiegraad)
			{
				case .Onbekend:
					renderer.strokeColor = UIColor.grayColor()
					
				case .Onbestaand:
					renderer.strokeColor = UIColor.redColor()
					
				case .Bestaand:
					renderer.strokeColor = UIColor.greenColor()
			}
			
			return renderer
		}
		else
		{
			return MKOverlayRenderer(overlay: overlay)
		}
	}
}