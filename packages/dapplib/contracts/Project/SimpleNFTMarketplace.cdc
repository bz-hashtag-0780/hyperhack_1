import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import SimpleNFT from "./SimpleNFT.cdc"
import FlowToken from "../Flow/FlowToken.cdc"
import FungibleToken from "../Flow/FungibleToken.cdc"
import HyperverseAuth from "../Hyperverse/HyperverseAuth.cdc"

pub contract SimpleNFTMarketplace: IHyperverseModule, IHyperverseComposable {

    /**************************************** METADATA ****************************************/

    access(contract) let metadata: HyperverseModule.ModuleMetadata
    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(id: String)
    access(contract) var clientTenants: {Address: String}
    pub fun getClientTenantID(account: Address): String? {
        return self.clientTenants[account]
    }
    access(contract) var tenants: @{String: Tenant{IHyperverseComposable.ITenant, IState}}
    pub fun getTenant(id: String): &Tenant{IHyperverseComposable.ITenant, IState} {
        return &self.tenants[id] as &Tenant{IHyperverseComposable.ITenant, IState}
    }
    access(contract) var aliases: {String: String}
    pub fun addAlias(auth: &HyperverseAuth.Auth, new: String) {
        let original = auth.owner!.address.toString()
                        .concat(".")
                        .concat(self.getType().identifier)
                        
        self.aliases[new] = original
    }


    pub resource interface IState {
        pub let tenantID: String
        pub var holder: Address
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant, IState {
        pub let tenantID: String
        pub var holder: Address

        init(_tenantID: String, _holder: Address) {
            self.tenantID = _tenantID
            self.holder = _holder
        }
    }

    pub fun instance(auth: &HyperverseAuth.Auth) {
        pre {
            self.clientTenants[auth.owner!.address] == nil: "This account already have a Tenant from this contract."
        }

        // If Jacob is the one calling instance...  
        // STenantID = "{Jacob's Address}.A.{Address of Contract}.{SimpleNFTMarketplace}
        // JacobsAddress.A.AddressOfContract.SimpleNFTMarketplace
        var STenantID: String = auth.owner!.address.toString()
                                .concat(".")
                                .concat(self.getType().identifier)

        /* Dependencies */
        if SimpleNFT.getClientTenantID(account: auth.owner!.address) == nil {
            SimpleNFT.instance(auth: auth)                   
        }
        SimpleNFT.addAlias(auth: auth, new: STenantID)
        
        self.tenants[STenantID] <-! create Tenant(_tenantID: STenantID, _holder: auth.owner!.address)
        self.addAlias(auth: auth, new: STenantID)
        
        self.clientTenants[auth.owner!.address] = STenantID
        emit TenantCreated(id: STenantID)
    }

    /**************************************** PACKAGE ****************************************/

    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath
   
    pub resource interface PackagePublic {
       pub fun SimpleNFTPackagePublic(): &SimpleNFT.Package{SimpleNFT.PackagePublic}
       pub fun borrowSaleCollectionPublic(tenantID: String): &SaleCollection{SalePublic}
    }
    
    // For users... so they will need a SimpleNFTPackage because then why else would you
    // be creating a Storefront. You're creating a storefront for YOUR NFTs, so those
    // NFTs must already exist.
    pub resource Package: PackagePublic {
        pub let SimpleNFTPackage: Capability<&SimpleNFT.Package>
        pub fun SimpleNFTPackagePublic(): &SimpleNFT.Package{SimpleNFT.PackagePublic} {
            return self.SimpleNFTPackage.borrow()! as &SimpleNFT.Package{SimpleNFT.PackagePublic}
        }
        
        pub let FlowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>

        pub var salecollections: @{String: SaleCollection}
    
        pub fun setup(tenantID: String) {
            pre {
                SimpleNFTMarketplace.tenants[tenantID] != nil: "This tenantID does not exist."
            }
            self.salecollections[tenantID] <-! create SaleCollection(tenantID, _nftPackage: self.SimpleNFTPackage, _ftVault: self.FlowTokenVault)
        }

        pub fun borrowSaleCollection(tenantID: String): &SaleCollection {
            let original = SimpleNFTMarketplace.aliases[tenantID]!
            if self.salecollections[original] == nil {
                self.setup(tenantID: original)
            }
            return &self.salecollections[original] as &SaleCollection
        }
        pub fun borrowSaleCollectionPublic(tenantID: String): &SaleCollection{SalePublic} {
            return self.borrowSaleCollection(tenantID: tenantID)
        }

        init(
            _SimpleNFTPackage: Capability<&SimpleNFT.Package>,
            _FlowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>) 
        {
            self.SimpleNFTPackage = _SimpleNFTPackage
            self.FlowTokenVault = _FlowTokenVault
            self.salecollections <- {} 
        }

        destroy() {
            destroy self.salecollections
        }
    }

    pub fun getPackage(
        SimpleNFTPackage: Capability<&SimpleNFT.Package>,
        FlowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>
    ): @Package {
        pre {
            SimpleNFTPackage.borrow() != nil: "This is not a correct SimpleNFT.Package! Or you don't have one yet."
        }
        return <- create Package(_SimpleNFTPackage: SimpleNFTPackage, _FlowTokenVault: FlowTokenVault)
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event SimpleNFTMarketplaceInitialized()

    pub event ForSale(id: UInt64, price: UFix64)

    pub event NFTPurchased(id: UInt64, price: UFix64)

    pub event SaleWithdrawn(id: UInt64)

    pub resource interface SalePublic {
        pub fun purchase(simpleNFTTenantID: String, id: UInt64, recipient: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}, buyTokens: @FungibleToken.Vault)
        pub fun idPrice(simpleNFTTenantID: String, id: UInt64): UFix64?
        pub fun getIDs(simpleNFTTenantID: String): [UInt64]
    }

    pub resource SaleCollection: SalePublic {
        pub let tenantID: String
        pub var forSale: {String: {UInt64: UFix64}}
        access(self) let FlowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>
        access(self) let SimpleNFTPackage: Capability<&SimpleNFT.Package>

        init (_ tenantID: String, _nftPackage: Capability<&SimpleNFT.Package>, _ftVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>) {
            self.tenantID = tenantID
            self.forSale = {}
            self.FlowTokenVault = _ftVault
            self.SimpleNFTPackage = _nftPackage
        }

        pub fun unlistSale(simpleNFTTenantID: String, id: UInt64) {
            self.forSale[simpleNFTTenantID]!.remove(key: id)

            emit SaleWithdrawn(id: id)
        }

        // You pass in the tenantID of the SimpleNFT you'll be listing for sale.
        pub fun listForSale(simpleNFTTenantID: String, ids: [UInt64], price: UFix64) {
            pre {
                price > 0.0:
                    "Cannot list a NFT for 0.0"
            }
            if self.forSale[simpleNFTTenantID] == nil {
                self.forSale[simpleNFTTenantID] = {}
            }

            var ownedNFTs = self.SimpleNFTPackage.borrow()!.borrowCollection(tenantID: simpleNFTTenantID).getIDs()
            for id in ids {
                if (ownedNFTs.contains(id)) {
                    self.forSale[simpleNFTTenantID]!.insert(key: id, price)

                    emit ForSale(id: id, price: price)
                }
            }
        }

        pub fun purchase(simpleNFTTenantID: String, id: UInt64, recipient: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}, buyTokens: @FungibleToken.Vault) {
            pre {
                self.forSale[simpleNFTTenantID]![id] != nil:
                    "No NFT matching this id for sale!"
                buyTokens.balance >= (self.forSale[simpleNFTTenantID]![id]!):
                    "Not enough tokens to buy the NFT!"
            }
            let buyTokens <- buyTokens as! @FlowToken.Vault
            let price = self.forSale[simpleNFTTenantID]![id]!
            let vaultRef = self.FlowTokenVault.borrow()!
            vaultRef.deposit(from: <-buyTokens)
            let token <- self.SimpleNFTPackage.borrow()!.borrowCollection(tenantID: self.tenantID).withdraw(withdrawID: id)
            recipient.deposit(token: <-token)
            self.unlistSale(simpleNFTTenantID: simpleNFTTenantID, id: id)
            emit NFTPurchased(id: id, price: price)
        }

        pub fun idPrice(simpleNFTTenantID: String, id: UInt64): UFix64? {
            return self.forSale[simpleNFTTenantID]![id]
        }

        pub fun getIDs(simpleNFTTenantID: String): [UInt64] {
            if self.forSale[simpleNFTTenantID] == nil {
                self.forSale[simpleNFTTenantID] = {}
            }
            return self.forSale[simpleNFTTenantID]!.keys
        }
    }

    init() {
        self.clientTenants = {}
        self.tenants <- {}
        self.aliases = {}

        self.PackageStoragePath = /storage/SimpleNFTMarketplacePackage
        self.PackagePrivatePath = /private/SimpleNFTMarketplacePackage
        self.PackagePublicPath = /public/SimpleNFTMarketplacePackage

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "SimpleNFT Marketplace", 
            _authors: [HyperverseModule.Author(_address: 0x26a365de6d6237cd, _externalLink: "https://www.decentology.com/")], 
            _version: "0.0.1", 
            _publishedAt: getCurrentBlock().timestamp,
            _externalLink: "",
            _secondaryModules: [{Address(0x26a365de6d6237cd): "SimpleNFT"}]
        )

        emit SimpleNFTMarketplaceInitialized()
    }
}