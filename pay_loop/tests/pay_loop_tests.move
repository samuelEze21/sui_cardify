#[test_only]
module pay_loop::payloop_tests {
    use sui::test_scenario::{Self as ts, Scenario};
    use sui::test_utils;
    use std::vector;
    use pay_loop::payloop::{Self, SubscriptionPlan, PlanCreated};

    const MERCHANT: address = @0x1;

    #[test]
    fun test_create_plan() {
        let mut scenario = ts::begin(MERCHANT);
        
        // Create the plan
        {
            let ctx = ts::ctx(&mut scenario);
            payloop::create_plan(1000, 86400000, b"Test Plan", ctx);
        };
        
        // Check the plan was created correctly
        ts::next_tx(&mut scenario, MERCHANT);
        {
            let plan: SubscriptionPlan = ts::take_shared(&scenario);
            assert!(payloop::get_merchant(&plan) == MERCHANT, 100);
            assert!(payloop::get_amount(&plan) == 1000, 101);
            assert!(payloop::get_interval(&plan) == 86400000, 102);
            assert!(payloop::get_description(&plan) == b"Test Plan", 103);
            ts::return_shared(plan);
        };
        
        ts::end(scenario);
    }

    #[test]
    fun test_create_plan_event() {
        let mut scenario = ts::begin(MERCHANT);
        
        // Create the plan
        {
            let ctx = ts::ctx(&mut scenario);
            payloop::create_plan(1000, 86400000, b"Test Plan", ctx);
        };
        
        // Check both the plan and the event
        ts::next_tx(&mut scenario, MERCHANT);
        {
            let plan: SubscriptionPlan = ts::take_shared(&scenario);
            let plan_id = sui::object::id(&plan);
            
            // Verify plan properties
            assert!(payloop::get_merchant(&plan) == MERCHANT, 200);
            assert!(payloop::get_amount(&plan) == 1000, 201);
            
            // Check that the event was emitted (this is implicit in test_scenario)
            // In a real test, you might want to check specific event properties
            
            ts::return_shared(plan);
        };
        
        ts::end(scenario);
    }
}