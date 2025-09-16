module MyModule::NFTTradingBoard {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::string::String;

    /// Struct representing an NFT listing on the trading board
    struct NFTListing has store, key {
        nft_id: u64,                  // Simple NFT identifier
        creator: address,             // Creator of the NFT
        collection_name: String,      // Name of the NFT collection
        token_name: String,           // Name of the token
        seller: address,              // Address of the NFT seller
        price: u64,                   // Price in AptosCoin
        is_active: bool,              // Whether the listing is still active
    }

    /// Error codes
    const E_LISTING_NOT_ACTIVE: u64 = 1;
    const E_INSUFFICIENT_PAYMENT: u64 = 2;

    /// Function to list an NFT for sale on the trading board
    public fun list_nft_for_sale(
        seller: &signer, 
        nft_id: u64,
        creator: address,
        collection_name: String,
        token_name: String,
        price: u64
    ) {
        let seller_addr = signer::address_of(seller);
        
        // Create the NFT listing
        let listing = NFTListing {
            nft_id,
            creator,
            collection_name,
            token_name,
            seller: seller_addr,
            price,
            is_active: true,
        };
        
        // Store the listing under seller's account
        move_to(seller, listing);
    }

    /// Function to purchase an NFT from the trading board
    public fun purchase_nft(
        buyer: &signer,
        seller_addr: address,
        payment_amount: u64
    ) acquires NFTListing {
        let listing = borrow_global_mut<NFTListing>(seller_addr);
        
        // Verify listing is active and payment is sufficient
        assert!(listing.is_active, E_LISTING_NOT_ACTIVE);
        assert!(payment_amount >= listing.price, E_INSUFFICIENT_PAYMENT);
        
        // Transfer payment from buyer to seller
        let payment = coin::withdraw<AptosCoin>(buyer, listing.price);
        coin::deposit<AptosCoin>(seller_addr, payment);
        
        // Mark listing as inactive (NFT ownership transfer would happen off-chain)
        listing.is_active = false;
    }
}