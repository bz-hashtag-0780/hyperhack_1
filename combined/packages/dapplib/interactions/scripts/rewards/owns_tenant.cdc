import Rewards from "../../../contracts/Project/Rewards.cdc"

pub fun main(account: Address): [String] {
    return Rewards.getClientTenants(account: account)
}