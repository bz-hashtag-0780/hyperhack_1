pub contract HyperverseModule {
    
    pub struct ModuleMetadata {
        pub var title: String
        pub var authors: [Author]
        pub var version: String
        pub var publishedAt: UFix64
        pub var externalURI: String
        pub var secondaryModules: [{Address: String}]?

        init(
            _title: String, 
            _authors: [Author], 
            _version: String, 
            _publishedAt: UFix64,
            _externalURI: String,
            _secondaryModules: [{Address: String}]?,
        ) {
            self.title = _title
            self.authors = _authors
            self.version = _version
            self.publishedAt = _publishedAt
            self.externalURI = _externalURI
            self.secondaryModules = _secondaryModules
        }
    }

    pub struct Author {
        pub var address: Address
        pub var externalURI: String

        init(_address: Address, _externalURI: String) {
            self.address = _address
            self.externalURI = _externalURI
        }
    }

}