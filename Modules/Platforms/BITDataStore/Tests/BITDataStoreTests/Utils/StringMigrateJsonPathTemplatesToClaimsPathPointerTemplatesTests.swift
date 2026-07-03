import Testing
@testable import BITDataStore

struct StringMigrateJsonPathTemplatesToClaimsPathPointerTemplatesTests {

  @Test
  func migrateJsonPathTemplatesToClaimsPathPointerTemplates_oneTemplate_migrates() {
    let result = "Category {{$.categoryCode}}".migrateJsonPathTemplatesToClaimsPathPointerTemplates()

    #expect(result == "Category {{[\"categoryCode\"]}}")
  }

  @Test
  func migrateJsonPathTemplatesToClaimsPathPointerTemplates_multipleTemplates_migrates() {
    let result = "Category {{$.categoryCode}}, name: {{$.name}}".migrateJsonPathTemplatesToClaimsPathPointerTemplates()

    #expect(result == "Category {{[\"categoryCode\"]}}, name: {{[\"name\"]}}")
  }

  @Test
  func migrateJsonPathTemplatesToClaimsPathPointerTemplates_claimsPathPointerTemplate_noMigration() {
    let result = "Category {{[\"categoryCode\"]}}".migrateJsonPathTemplatesToClaimsPathPointerTemplates()

    #expect(result == "Category {{[\"categoryCode\"]}}")
  }

  @Test
  func migrateJsonPathTemplatesToClaimsPathPointerTemplates_invalidJsonPath_noMigration() {
    let result = "Category {{$..categoryCode}}".migrateJsonPathTemplatesToClaimsPathPointerTemplates()

    #expect(result == "Category {{$..categoryCode}}")
  }
}
