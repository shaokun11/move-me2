spec aptos_framework::version {
    spec module {
        pragma verify = true;
        pragma aborts_if_is_strict;
    }

    spec set_version(account: &signer, major: u64) {
        use std::signer;
        use aptos_framework::chain_status;
        use aptos_framework::timestamp;
        use aptos_framework::stake;
        use aptos_framework::coin::CoinInfo;
        use aptos_framework::aptos_coin::AptosCoin;
        use aptos_framework::transaction_fee;
        use aptos_framework::staking_config;
        use aptos_framework::reconfiguration;

        // TODO: set because of timeout (property proved)
        pragma verify_duration_estimate = 120;
        include transaction_fee::RequiresCollectedFeesPerValueLeqBlockAptosSupply;
        include staking_config::StakingRewardsConfigRequirement;
        requires chain_status::is_operating();
        requires timestamp::spec_now_microseconds() >= reconfiguration::last_reconfiguration_time();
        requires exists<stake::ValidatorFees>(@aptos_framework);
        requires exists<CoinInfo<AptosCoin>>(@aptos_framework);

        aborts_if !exists<SetVersionCapability>(signer::address_of(account));
        aborts_if !exists<Version>(@aptos_framework);

        let old_major = global<Version>(@aptos_framework).major;
        aborts_if !(old_major < major);

        ensures global<Version>(@aptos_framework).major == major;
    }

    /// Abort if resource already exists in `@aptos_framwork` when initializing.
    spec initialize(aptos_framework: &signer, initial_version: u64) {
        use std::signer;

        aborts_if signer::address_of(aptos_framework) != @aptos_framework;
        aborts_if exists<Version>(@aptos_framework);
        aborts_if exists<SetVersionCapability>(@aptos_framework);
        ensures exists<Version>(@aptos_framework);
        ensures exists<SetVersionCapability>(@aptos_framework);
        ensures global<Version>(@aptos_framework) == Version { major: initial_version };
        ensures global<SetVersionCapability>(@aptos_framework) == SetVersionCapability {};
    }

    /// This module turns on `aborts_if_is_strict`, so need to add spec for test function `initialize_for_test`.
    spec initialize_for_test {
        // Don't verify test functions.
        pragma verify = false;
    }
}
