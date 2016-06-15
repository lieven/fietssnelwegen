//
//  AppDelegate.swift
//  Fietssnelwegen
//
//  Created by Lieven Dekeyser on 03/06/16.
//  Copyright © 2016 Plane Tree Software. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
	{
		let window = UIWindow()
		window.backgroundColor = UIColor.white()
		window.rootViewController = MapViewController()
		
		self.window = window

		window.makeKeyAndVisible()

		return true
	}
}

