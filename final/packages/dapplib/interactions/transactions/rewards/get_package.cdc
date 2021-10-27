import Rewards from 0x26a365de6d6237cd
import SimpleNFT from 0x26a365de6d6237cd

// THIS IS THE FIRST THING YOU RUN - EVEN BEFORE GETTING A TENANT IN 'instance.cdc'
// Will only be run 1 time per user - ever. So even if they need this
// collection as dependencies, etc.
transaction() {

    prepare(signer: AuthAccount) {
        let SimpleNFTPackage = signer.getCapability<&SimpleNFT.Package>(SimpleNFT.PackagePrivatePath)
        signer.save(<- Rewards.getPackage(SimpleNFTPackage: SimpleNFTPackage), to: Rewards.PackageStoragePath)
        signer.link<&Rewards.Package>(Rewards.PackagePrivatePath, target: Rewards.PackageStoragePath)
        signer.link<&Rewards.Package{Rewards.PackagePublic}>(Rewards.PackagePublicPath, target: Rewards.PackageStoragePath)
    }

    execute {
        log("Signer has a Rewards.Package.")
    }
}
