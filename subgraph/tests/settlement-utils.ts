import { newMockEvent } from "matchstick-as"
import { ethereum, BigInt, Address } from "@graphprotocol/graph-ts"
import {
  DailySettlement,
  OwnershipTransferred
} from "../generated/Settlement/Settlement"

export function createDailySettlementEvent(
  totalTokensDistributed: BigInt,
  timestamp: BigInt
): DailySettlement {
  let dailySettlementEvent = changetype<DailySettlement>(newMockEvent())

  dailySettlementEvent.parameters = new Array()

  dailySettlementEvent.parameters.push(
    new ethereum.EventParam(
      "totalTokensDistributed",
      ethereum.Value.fromUnsignedBigInt(totalTokensDistributed)
    )
  )
  dailySettlementEvent.parameters.push(
    new ethereum.EventParam(
      "timestamp",
      ethereum.Value.fromUnsignedBigInt(timestamp)
    )
  )

  return dailySettlementEvent
}

export function createOwnershipTransferredEvent(
  previousOwner: Address,
  newOwner: Address
): OwnershipTransferred {
  let ownershipTransferredEvent = changetype<OwnershipTransferred>(
    newMockEvent()
  )

  ownershipTransferredEvent.parameters = new Array()

  ownershipTransferredEvent.parameters.push(
    new ethereum.EventParam(
      "previousOwner",
      ethereum.Value.fromAddress(previousOwner)
    )
  )
  ownershipTransferredEvent.parameters.push(
    new ethereum.EventParam("newOwner", ethereum.Value.fromAddress(newOwner))
  )

  return ownershipTransferredEvent
}
