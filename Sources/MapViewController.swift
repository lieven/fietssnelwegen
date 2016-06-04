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
		
		if let path = NSBundle.mainBundle().pathForResource("realisatiegraad", ofType: "txt")
		{
			let lines : [ NSString ]
			
			do
			{
				let text = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
				lines = text.componentsSeparatedByString("\n")
			}
			catch
			{
				return
			}
			
			
			var nummering : String?
			var vanNaar : String?
			var segmenten : [ FietssnelwegSegment ]?
			
			var coordinaten : [ CLLocationCoordinate2D ]?
			var realisatiegraad : FietssnelwegSegment.RealisatieGraad?
			
			
			let pushSnelweg =
			{
				if let segmenten = segmenten, nummering = nummering, vanNaar = vanNaar
				{
					fietssnelwegen.append(Fietssnelweg(segmenten: segmenten, nummer: nummering, vanNaar: vanNaar))
				}
				segmenten = nil
				nummering = nil
				realisatiegraad = nil
				coordinaten = nil
			}
			
			let pushSegment =
			{
				if coordinaten != nil && realisatiegraad != nil
				{
					let polyline = MKPolyline(coordinates: &coordinaten!, count: coordinaten!.count)
					
					segmenten?.append(FietssnelwegSegment(polyline: polyline, realisatiegraad: realisatiegraad!))
				}
				
				coordinaten = nil
				realisatiegraad = nil
			}
			
			
			for line in lines
			{
				let components = line.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).componentsSeparatedByString("\t")
				
				if (line.hasPrefix("\t\t") && components.count > 1)
				{
					// coordinate
					let latitude = components[0] as NSString
					let longitude = components[1] as NSString
					
					coordinaten?.append(CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue))
					
				}
				else if (line.hasPrefix("\t") && components.count > 0)
				{
					pushSegment()
										
					switch (components[0])
					{
						case "onbestaand":
							realisatiegraad = .Onbestaand
						
						case "bestaand":
							realisatiegraad = .Bestaand
						
						default:
							realisatiegraad = .Onbekend
					}
					
					coordinaten = []
				}
				else if (components.count > 1)
				{
					pushSegment()
					pushSnelweg()
					
					nummering = components[0]
					vanNaar = components[1]
					segmenten = []
				}
			}
			
			pushSegment()
			pushSnelweg()
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