<?php

//$url = 'https://services.arcgis.com/tR9PyAwW7kYhL5ua/arcgis/rest/services/FSW_Vlaanderen_WGS84/FeatureServer/0/query?f=json&where=1%3D1&returnGeometry=true&spatialRel=esriSpatialRelIntersects&maxAllowableOffset=0.001&outFields=*&outSR=4326&geometryPrecision=6';

$url = 'fietssnelwegen.json';

$text = file_get_contents($url);

$json = json_decode($text, true);

$features = $json['features'];

$snelwegen = array();

foreach ($features as $feature)
{
	$attributes = $feature['attributes'];
	
	$nummering = $attributes['nummering'];
	
	$lengte = (double)$attributes['lengte_km'];
	$gerealiseerd = (double)$attributes['gerealisee'];
	
	$realisatiegraad = 'onbekend';
	if ($gerealiseerd == 0.0)
	{
		$realisatiegraad = 'onbestaand';
	}
	else if ($gerealiseerd == $lengte)
	{
		$realisatiegraad = 'bestaand';
	}
	
	
	$segmenten = array();
	
	$paths = $feature['geometry']['paths'];
	foreach ($paths as $points)
	{
		$coordinaten = array();
		
		foreach ($points as $point)
		{
			$coordinaten[] = $point;
		}
		
		$segmenten[] = array
		(
			'realisatiegraad' => $realisatiegraad,
			'coordinaten' => $coordinaten
		);
	}
	
	$snelwegen[$nummering] = array
	(
		'van_naar' => $attributes['van_naar'],
		'segmenten' => $segmenten
	);
}


ksort($snelwegen, SORT_NATURAL);


foreach ($snelwegen as $nummering => $snelweg)
{
	printf("%s\t%s\n", $nummering, $snelweg['van_naar']);
	foreach ($snelweg['segmenten'] as $segment)
	{
		printf("\t%s\n", $segment['realisatiegraad']);
		foreach ($segment['coordinaten'] as $coordinaat)
		{
			printf("\t\t%s\t%s\n", $coordinaat[1], $coordinaat[0]);
		}
	}
}
