@testable import KsApi
import Prelude

extension CategoriesEnvelope {
  internal static let template = CategoriesEnvelope(
    categories: [
      .art,
      .filmAndVideo,
      .illustration,
      .documentary
    ]
  )
}
