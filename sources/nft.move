module MyModule::SimpleNFT {
    use std::string::{Self, String};
    use std::vector;
    use aptos_framework::account;
    use aptos_framework::signer;
    use aptos_token::token;

    // Error codes
    const ENFT_ALREADY_EXISTS: u64 = 1;
    const ENFT_DOESNT_EXIST: u64 = 2;

    // Struct to store NFT metadata
    struct NFTCollection has key {
        token_data_id: token::TokenDataId,
        minted_count: u64,
    }

    // Initialize the NFT collection
    public fun initialize_collection(creator: &signer, collection_name: String, description: String) {
        let collection_mutation_config = vector<bool>[true, true, true];
        let token_mutation_config = vector<bool>[true, true, true, true, true];

        token::create_collection(
            creator,
            string::utf8(b"Simple NFT Collection"),
            description,
            collection_name,
            collection_mutation_config,
            token_mutation_config
        );

        move_to(creator, NFTCollection {
            token_data_id: token::create_tokendata(
                creator,
                collection_name,
                string::utf8(b"NFT"),
                description,
                1,
                string::utf8(b"https://example.com/nft/"),
                signer::address_of(creator),
                1,
                0,
                token_mutation_config,
                vector<String>[],
                vector<vector<u8>>[],
                vector<String>[]
            ),
            minted_count: 0
        });
    }

    // Mint a new NFT
    public fun mint_nft(receiver: &signer) acquires NFTCollection {
        let receiver_addr = signer::address_of(receiver);
        let nft_collection = borrow_global_mut<NFTCollection>(@MyModule);
        
        token::mint_token(
            receiver,
            nft_collection.token_data_id,
            1
        );
        nft_collection.minted_count = nft_collection.minted_count + 1;
    }
}