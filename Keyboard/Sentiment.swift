import UIKit

enum Sentiment {
  case neutral
  case positive
  case negative

  var emoji: String {
    switch self {
    case .neutral:
      return "😐"
    case .positive:
      return "😃"
    case .negative:
      return "😔"
    }
  }

  var color: UIColor? {
    switch self {
    case .neutral:
      return UIColor.SA_Blue
    case .positive:
      return UIColor.SA_Green
    case .negative:
      return UIColor.SA_Red
    }
  }
}
