module pay_loop::payloop {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::coin::Coin;
    use sui::clock::Clock;
    use sui::event;
    use sui::transfer;

    // constants 
    const ENotOwner: u64 = 0;
    const EInactive: u64 = 1;
    const EInsufficientFunds: u64 = 2;
    const EPaymentNotDue: u64 = 3;

    // structs 
    public struct SubscriptionPlan has key {
        id: UID,
        merchant: address,
        amount: u64,
        interval: u64,
        description: vector<u8>,
    }

    public struct SubscriberVault<phantom CoinType> has key {
        id: UID,
        subscriber: address,
        plan_id: ID,
        next_due: u64,
        balance: Coin<CoinType>,
        active: bool,
    }

    // event structs
    public struct PlanCreated has copy, drop {
        plan_id: ID,
        merchant: address,
    }
    public struct Subscribed has copy, drop { 
        vault_id: ID, 
        subscriber: address, 
        plan_id: ID 
    }
    public struct Renewed has copy, drop { 
        vault_id: ID, 
        amount: u64 
    }
    public struct Canceled has copy, drop { 
        vault_id: ID 
    }
    #[allow(unused_field)]
    public struct Claimed has copy, drop { 
        vault_id: ID, 
        amount: u64 
    }

    // create plan entry function
    public entry fun create_plan(
        amount: u64,
        interval: u64,
        description: vector<u8>,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        let plan = SubscriptionPlan {
            id: object::new(ctx),
            merchant: sender,
            amount,
            interval,
            description,
        };
        let plan_id = object::id(&plan);
        transfer::share_object(plan);
        event::emit(PlanCreated { plan_id, merchant: sender });
    }

    // Getter functions for testing
    public fun get_merchant(plan: &SubscriptionPlan): address {
        plan.merchant
    }
    public fun get_amount(plan: &SubscriptionPlan): u64 {
        plan.amount
    }
    public fun get_interval(plan: &SubscriptionPlan): u64 {
        plan.interval
    }
    public fun get_description(plan: &SubscriptionPlan): vector<u8> {
        plan.description
    }
    public fun get_plan_id(event: &PlanCreated): ID {
        event.plan_id
    }
    public fun get_plan_merchant(event: &PlanCreated): address {
        event.merchant
    }
}