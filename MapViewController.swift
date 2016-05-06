import UIKit
import MapKit
import CoreData


class MapViewController: UIViewController {

  @IBOutlet weak var mapView: MKMapView!

  var locations = [Location]()
  var managedObjectContext: NSManagedObjectContext!

  @IBAction func showUser() {
    let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
    mapView.setRegion(mapView.regionThatFits(region), animated: true)

  }

  @IBAction func showLocations() {

  }

  override func viewDidLoad() {
    super.viewDidLoad()
    updateLocations()
  }

  func updateLocations() {
    mapView.removeAnnotations(locations)

    let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)

    let fetchRequest = NSFetchRequest()
    fetchRequest.entity = entity
    locations = try! managedObjectContext.executeFetchRequest(fetchRequest) as! [Location]

    mapView.addAnnotations(locations)
  }

  func regionForAnnotations(annotations: [MKAnnotation]) -> MKCoordinateRegion {
    var region: MKCoordinateRegion

    switch annotations.count {
    case 0:
      region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
    case 1:
      let annotation = annotations[annotations.count - 1]
      region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
    default:
      var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
      var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: 180)

      for annotation in annotations {
        topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
        topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
        bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
        bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
      }

      let centerLatitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2
      let centerLongitude = topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2
      let center = CLLocationCoordinate2D(latitude: centerLatitude, longitude:  centerLongitude)

      let extraSpace = 1.1
      let span = MKCoordinateSpan(latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace, longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
      region = MKCoordinateRegion(center: center, span: span)
    }


    return mapView.regionThatFits(region)
  }
}

extension MapViewController: MKMapViewDelegate {

}