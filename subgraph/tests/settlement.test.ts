import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { BigInt, Address } from "@graphprotocol/graph-ts"
import { DailySettlement } from "../generated/schema"
import { DailySettlement as DailySettlementEvent } from "../generated/Settlement/Settlement"
import { handleDailySettlement } from "../src/settlement"
import { createDailySettlementEvent } from "./settlement-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let totalTokensDistributed = BigInt.fromI32(234)
    let timestamp = BigInt.fromI32(234)
    let newDailySettlementEvent = createDailySettlementEvent(
      totalTokensDistributed,
      timestamp
    )
    handleDailySettlement(newDailySettlementEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("DailySettlement created and stored", () => {
    assert.entityCount("DailySettlement", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "DailySettlement",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "totalTokensDistributed",
      "234"
    )
    assert.fieldEquals(
      "DailySettlement",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "timestamp",
      "234"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
