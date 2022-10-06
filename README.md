# Example Portal Fast Withdrawal

In a world where Ethereum finality takes ~18 minutes and Wormhole offers instant, un-finalized messaging in addition to finalized messaging, this repo imagines a Portal which can offer even faster transfers.

_Gotta go fast!_

## Concept

Provide liquidity for fast withdrawals in exchange for fee emissions (at the risk of never receiving the Portal transfer due to rollbacks). If pooled funds exist on the target chain, the user can complete their transfer immediately. If not, they can complete their transfer after their portal funds arrive.

## Progress

- [x] Send fast transfer and portal transfer
- [ ] Redeem fast transfer to user, 1% to pool
- [ ] Redeem portal transfer to pool
- [ ] Setup pool via creating and registering of LP token
- [ ] Portal ABI parity
- [ ] Ownable and owner-only registration

## Disclaimer

This is an example only, not suitable for practically anything!
