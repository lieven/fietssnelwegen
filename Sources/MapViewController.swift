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
		mapView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
		mapView.delegate = self
		mapView.mapType = .standard
		
		self.view.addSubview(mapView)
		
		self.mapView = mapView
		
		loadPaths()
	}
	
	
	func loadPaths()
	{
		var fietssnelwegen : [ Fietssnelweg ] = []
		
		if let path = Bundle.main().pathForResource("realisatiegraad", ofType: "txt")
		{
			let lines : [ NSString ]
			
			do
			{
				let text = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
				lines = text.components(separatedBy: "\n")
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
				let components = line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).components(separatedBy: "\t")
				
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
							realisatiegraad = .onbestaand
						
						case "bestaand":
							realisatiegraad = .bestaand
						
						default:
							realisatiegraad = .onbekend
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
				mapView.addOverlays(fietssnelweg.segmenten, level: .aboveRoads)
				
			}
		}
	}
	
	func pathArrayToPolyline(_ inPathArray : NSArray) -> MKPolyline?
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
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
	{
		if let segment = overlay as? FietssnelwegSegment
		{
			let renderer = MKPolylineRenderer(polyline: segment.polyline)
			renderer.lineWidth = 4.0
			
			switch (segment.realisatiegraad)
			{
				case .onbekend:
					renderer.strokeColor = UIColor.gray()
					
				case .onbestaand:
					renderer.strokeColor = UIColor.red()
					
				case .bestaand:
					renderer.strokeColor = UIColor.green()
			}
			
			return renderer
		}
		else
		{
			return MKOverlayRenderer(overlay: overlay)
		}
	}
}
