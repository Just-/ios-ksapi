import Argo
import Prelude
import XCTest
@testable import KsApi

class DiscoveryParamsTests: XCTestCase {

  func testDefault() {
    let params = DiscoveryParams.defaults
    XCTAssertNil(params.staffPicks)
  }

  func testQueryParams() {
    XCTAssertEqual([:], DiscoveryParams.defaults.queryParams)

    let params = DiscoveryParams.defaults
      |> DiscoveryParams.lens.staffPicks .~ true
      <> DiscoveryParams.lens.hasVideo .~ true
      <> DiscoveryParams.lens.starred .~ true
      <> DiscoveryParams.lens.backed .~ false
      <> DiscoveryParams.lens.social .~ true
      <> DiscoveryParams.lens.recommended .~ true
      <> DiscoveryParams.lens.similarTo .~ Project.template
      <> DiscoveryParams.lens.category .~ Category.art
      <> DiscoveryParams.lens.query .~ "wallet"
      <> DiscoveryParams.lens.state .~ .live
      <> DiscoveryParams.lens.sort .~ .popular
      <> DiscoveryParams.lens.page .~ 1
      <> DiscoveryParams.lens.perPage .~ 20
      <> DiscoveryParams.lens.seed .~ 123

    XCTAssertEqual([
      "staff_picks": "true",
      "has_video": "true",
      "backed": "-1",
      "social": "1",
      "recommended": "true",
      "category_id": "1",
      "term": "wallet",
      "state": "live",
      "starred": "1",
      "sort": "popularity",
      "page": "1",
      "per_page": "20",
      "seed": "123",
      "similar_to": Project.template.id.description
    ], params.queryParams)
  }

  func testEquatable() {
    let params = DiscoveryParams.defaults
    XCTAssertEqual(params, params)
  }

  func testStringConvertible() {
    let params = DiscoveryParams.defaults
    XCTAssertNotNil(params.description)
    XCTAssertNotNil(params.debugDescription)
  }

  func testPOTD() {
    let p1 = DiscoveryParams.defaults
      |> DiscoveryParams.lens.includePOTD .~ true
    XCTAssertEqual([:], p1.queryParams,
                   "POTD flag is not included when not staff picks + default sort.")

    let p2 = DiscoveryParams.defaults
      |> DiscoveryParams.lens.includePOTD .~ true
      |> DiscoveryParams.lens.staffPicks .~ true
    XCTAssertEqual(["staff_picks": "true", "include_potd": "true"],
                   p2.queryParams,
                   "POTD flag is included when staff picks + default sort.")

    let p3 = DiscoveryParams.defaults
      |> DiscoveryParams.lens.includePOTD .~ true
      |> DiscoveryParams.lens.staffPicks .~ true
      |> DiscoveryParams.lens.sort .~ .magic
    XCTAssertEqual(["staff_picks": "true", "include_potd": "true", "sort": "magic"],
                   p3.queryParams,
                   "POTD flag is included when staff picks + magic sort.")
  }

  func testDecode() {
    XCTAssertNil(DiscoveryParams.decode(JSON.parse([:])).value!.backed, "absent values aren't set")
    XCTAssertNil(DiscoveryParams.decode(JSON.parse(["backed": "nope"])).value, "invalid values error")

    // server logic
    XCTAssertEqual(true, DiscoveryParams.decode(JSON.parse(["has_video": "true"])).value?.hasVideo)
    XCTAssertEqual(true, DiscoveryParams.decode(JSON.parse(["has_video": "1"])).value?.hasVideo)
    XCTAssertEqual(true, DiscoveryParams.decode(JSON.parse(["has_video": "t"])).value?.hasVideo)
    XCTAssertEqual(true, DiscoveryParams.decode(JSON.parse(["has_video": "T"])).value?.hasVideo)
    XCTAssertEqual(true, DiscoveryParams.decode(JSON.parse(["has_video": "TRUE"])).value?.hasVideo)
    XCTAssertEqual(true, DiscoveryParams.decode(JSON.parse(["has_video": "on"])).value?.hasVideo)
    XCTAssertEqual(true, DiscoveryParams.decode(JSON.parse(["has_video": "ON"])).value?.hasVideo)
    XCTAssertEqual(false, DiscoveryParams.decode(JSON.parse(["has_video": "false"])).value?.hasVideo)
    XCTAssertEqual(false, DiscoveryParams.decode(JSON.parse(["has_video": "0"])).value?.hasVideo)
    XCTAssertEqual(false, DiscoveryParams.decode(JSON.parse(["has_video": "f"])).value?.hasVideo)
    XCTAssertEqual(false, DiscoveryParams.decode(JSON.parse(["has_video": "F"])).value?.hasVideo)
    XCTAssertEqual(false, DiscoveryParams.decode(JSON.parse(["has_video": "FALSE"])).value?.hasVideo)
    XCTAssertEqual(false, DiscoveryParams.decode(JSON.parse(["has_video": "off"])).value?.hasVideo)
    XCTAssertEqual(false, DiscoveryParams.decode(JSON.parse(["has_video": "OFF"])).value?.hasVideo)

    XCTAssertEqual(true, DiscoveryParams.decode(JSON.parse(["include_potd": "true"])).value?.includePOTD)
    XCTAssertEqual(true, DiscoveryParams.decode(JSON.parse(["recommended": "true"])).value?.recommended)
    XCTAssertEqual(true, DiscoveryParams.decode(JSON.parse(["staff_picks": "true"])).value?.staffPicks)

    XCTAssertEqual(40, DiscoveryParams.decode(JSON.parse(["page": "40"])).value?.page)
    XCTAssertEqual(41, DiscoveryParams.decode(JSON.parse(["per_page": "41"])).value?.perPage)
    XCTAssertEqual(42, DiscoveryParams.decode(JSON.parse(["seed": "42"])).value?.seed)

    XCTAssertNil(DiscoveryParams.decode(JSON.parse(["backed": "42"])).value)
    XCTAssertNil(DiscoveryParams.decode(JSON.parse(["backed": "0"])).value!.backed)
    XCTAssertEqual(true, DiscoveryParams.decode(JSON.parse(["backed": "1"])).value?.backed)
    XCTAssertEqual(false, DiscoveryParams.decode(JSON.parse(["backed": "-1"])).value?.backed)

    XCTAssertEqual(false, DiscoveryParams.decode(JSON.parse(["social": "-1"])).value?.social)
    XCTAssertEqual(false, DiscoveryParams.decode(JSON.parse(["starred": "-1"])).value?.starred)

    XCTAssertEqual("bugs", DiscoveryParams.decode(JSON.parse(["term": "bugs"])).value?.query)
    XCTAssertEqual(.magic, DiscoveryParams.decode(JSON.parse(["sort": "magic"])).value?.sort)
    XCTAssertEqual(.live, DiscoveryParams.decode(JSON.parse(["state": "live"])).value?.state)
  }
}
