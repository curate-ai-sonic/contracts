import {
  DailySettlement as DailySettlementEvent,
  OwnershipTransferred as OwnershipTransferredEvent,
} from "../generated/Settlement/Settlement"
import { DailySettlement, OwnershipTransferred } from "../generated/schema"

export function handleDailySettlement(event: DailySettlementEvent): void {
  let entity = new DailySettlement(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.totalTokensDistributed = event.params.totalTokensDistributed
  entity.timestamp = event.params.timestamp

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleOwnershipTransferred(
  event: OwnershipTransferredEvent,
): void {
  let entity = new OwnershipTransferred(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.previousOwner = event.params.previousOwner
  entity.newOwner = event.params.newOwner

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}
